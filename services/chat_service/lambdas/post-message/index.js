import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { Pinecone } from "@pinecone-database/pinecone";
import { OpenAIEmbeddings, ChatOpenAI } from "@langchain/openai";
import { PromptTemplate } from "@langchain/core/prompts";
import { RunnableSequence } from "@langchain/core/runnables";
import { StringOutputParser } from "@langchain/core/output_parsers";

const secretsClient = new SecretsManagerClient();
const dbClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dbClient);

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const getSecret = async (secretArn) => {
  const command = new GetSecretValueCommand({ SecretId: secretArn });
  const secret = await secretsClient.send(command);
  return JSON.parse(secret.SecretString);
};

const saveMessageToDb = async (chatId, sender, text) => {
  const timestamp = new Date().toISOString();
  await docClient.send(
    new PutCommand({
      TableName: process.env.CHATS_TABLE_NAME,
      Item: {
        PK: `CHAT#${chatId}`,
        SK: `MESSAGE#${timestamp}`,
        Sender: sender,
        Text: text,
      },
    })
  );
};

const saveChatMetadata = async (userId, chatId, title) => {
  await docClient.send(
    new PutCommand({
      TableName: process.env.CHATS_TABLE_NAME,
      Item: {
        PK: `USER#${userId}`,
        SK: `CHAT#${chatId}`,
        Title: title,
        CreatedAt: new Date().toISOString(),
      },
    })
  );
};

export const handler = async (event) => {
  console.log("Evento recibido:", JSON.stringify(event, null, 2));

  const method = event?.requestContext?.http?.method || event?.httpMethod || "";

  if (method === "OPTIONS") {
    return { statusCode: 204, headers: CORS_HEADERS, body: "" };
  }
  if (method !== "POST") {
    return {
      statusCode: 405,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: "Method Not Allowed" }),
    };
  }

  try {
    const body =
      typeof event.body === "string"
        ? JSON.parse(event.body || "{}")
        : event.body || {};
    const { question, userId } = body;
    let chatId = body.chatId ?? Date.now().toString();

    if (!userId || !question) {
      return {
        statusCode: 400,
        headers: CORS_HEADERS,
        body: JSON.stringify({ error: "userId and question are required." }),
      };
    }

    await saveMessageToDb(chatId, "user", question);
    await saveChatMetadata(userId, chatId, question);

    const [openAiSecrets, pineconeSecrets] = await Promise.all([
      getSecret(process.env.OPENAI_API_KEY_SECRET_ARN),
      getSecret(process.env.PINECONE_API_KEY_SECRET_ARN),
    ]);

    const embeddings = new OpenAIEmbeddings({
      openAIApiKey: openAiSecrets.apiKey,
    });
    const pinecone = new Pinecone({ apiKey: pineconeSecrets.apiKey });
    const index = pinecone.index(process.env.PINECONE_INDEX_NAME);
    const llm = new ChatOpenAI({
      openAIApiKey: openAiSecrets.apiKey,
      modelName: "gpt-4o",
    });

    const questionEmbedding = await embeddings.embedQuery(question);
    const queryResult = await index.query({
      topK: 5,
      vector: questionEmbedding,
      includeMetadata: true,
    });
    const context = (queryResult.matches || [])
      .map((m) => m.metadata?.text || "")
      .join("\n\n");

    const prompt = PromptTemplate.fromTemplate(
      `Context: {context}\n\nQuestion: {question}\n\nAnswer:`
    );
    const chain = RunnableSequence.from([
      { context: () => context, question: (i) => i.question },
      prompt,
      llm,
      new StringOutputParser(),
    ]);
    const answer = await chain.invoke({ question });

    await saveMessageToDb(chatId, "ai", answer);

    return {
      statusCode: 200,
      headers: CORS_HEADERS,
      body: JSON.stringify({ answer, chatId }),
    };
  } catch (error) {
    console.error("Error en post-message:", error);
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: "Failed to process chat request." }),
    };
  }
};
