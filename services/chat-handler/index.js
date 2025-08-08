import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { Pinecone } from "@pinecone-database/pinecone";
import { OpenAIEmbeddings, ChatOpenAI } from "@langchain/openai";
import { PromptTemplate } from "@langchain/core/prompts";
import { RunnableSequence } from "@langchain/core/runnables";
import { StringOutputParser } from "@langchain/core/output_parsers";

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
    const body = JSON.parse(event.body);
    const question = body.question;
    // const chatId = body.chatId; // We'll use this later

    // 1. Get secrets
    const [openAiSecrets, pineconeSecrets] = await Promise.all([
      getSecret(process.env.OPENAI_API_KEY_SECRET_ARN),
      getSecret(process.env.PINECONE_API_KEY_SECRET_ARN),
    ]);

    // 2. Initialize clients
    const embeddings = new OpenAIEmbeddings({
      openAIApiKey: openAiSecrets.apiKey,
    });
    const pinecone = new Pinecone({ apiKey: pineconeSecrets.apiKey });
    const index = pinecone.index(process.env.PINECONE_INDEX_NAME);
    const llm = new ChatOpenAI({
      openAIApiKey: openAiSecrets.apiKey,
      modelName: "gpt-4o",
    });

    // 3. Create embedding for the question
    const questionEmbedding = await embeddings.embedQuery(question);

    // 4. Query Pinecone for context
    const queryResult = await index.query({
      topK: 5,
      vector: questionEmbedding,
      includeMetadata: true,
    });
    const context = queryResult.matches
      .map((match) => match.metadata.text)
      .join("\n\n");

    // 5. Create a RAG chain with LangChain
    const template = `
      You are an intelligent assistant. Use the following context to answer the user's question.
      If you don't know the answer, just say that you don't know. Don't try to make up an answer.
      
      Context:
      {context}
      
      Question:
      {question}
      
      Answer:
    `;
    const prompt = PromptTemplate.fromTemplate(template);
    const chain = RunnableSequence.from([
      {
        context: () => context,
        question: (input) => input.question,
      },
      prompt,
      llm,
      new StringOutputParser(),
    ]);

    // 6. Invoke the chain to get the answer
    const answer = await chain.invoke({ question });

    // TODO: Save messages to DynamoDB here

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ answer }),
    };
  } catch (error) {
    console.error("Error in chat handler:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ error: "Failed to process chat request." }),
    };
  }
};
