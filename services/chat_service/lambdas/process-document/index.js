import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { Pinecone } from "@pinecone-database/pinecone";
import { OpenAIEmbeddings } from "@langchain/openai";
import { RecursiveCharacterTextSplitter } from "langchain/text_splitter";
import pdf from "pdf-parse";

// Function to get secrets from AWS Secrets Manager
const getSecret = async (secretArn) => {
  const secretsClient = new SecretsManagerClient();
  const command = new GetSecretValueCommand({ SecretId: secretArn });
  const secret = await secretsClient.send(command);
  return JSON.parse(secret.SecretString);
};

export const handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  try {
    // 1. Get secrets
    const [openAiSecrets, pineconeSecrets] = await Promise.all([
      getSecret(process.env.OPENAI_API_KEY_SECRET_ARN),
      getSecret(process.env.PINECONE_API_KEY_SECRET_ARN),
    ]);

    // 2. Get file info from S3 event
    const bucket = event.detail.bucket.name;
    const key = event.detail.object.key;

    // 3. Download PDF from S3
    const s3Client = new S3Client();
    const getObjectCmd = new GetObjectCommand({ Bucket: bucket, Key: key });
    const s3Object = await s3Client.send(getObjectCmd);
    const pdfBuffer = await s3Object.Body.transformToByteArray();

    // 4. Parse PDF text
    const pdfData = await pdf(pdfBuffer);

    // 5. Split text into chunks
    const splitter = new RecursiveCharacterTextSplitter({
      chunkSize: 1000,
      chunkOverlap: 200,
    });
    const docs = await splitter.createDocuments([pdfData.text]);
    console.log(`Split document into ${docs.length} chunks.`);

    // 6. Create embeddings
    const embeddings = new OpenAIEmbeddings({
      openAIApiKey: openAiSecrets.apiKey,
    });
    const vectors = await embeddings.embedDocuments(
      docs.map((doc) => doc.pageContent)
    );

    // 7. Initialize Pinecone and upsert vectors
    const pinecone = new Pinecone({ apiKey: pineconeSecrets.apiKey });
    const index = pinecone.index(process.env.PINECONE_INDEX_NAME);

    const vectorsToUpsert = docs.map((doc, i) => ({
      id: `${key}-${i}`,
      values: vectors[i],
      metadata: { text: doc.pageContent, source: key },
    }));

    // Upsert in batches
    for (let i = 0; i < vectorsToUpsert.length; i += 100) {
      const batch = vectorsToUpsert.slice(i, i + 100);
      await index.upsert(batch);
    }

    console.log(
      "Successfully processed and stored document vectors in Pinecone."
    );
    return { statusCode: 200, body: "Success" };
  } catch (error) {
    console.error("Error processing document:", error);
    return { statusCode: 500, body: "Error processing document" };
  }
};
