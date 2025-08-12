import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const dbClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dbClient);

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

const getChatsFromDb = async (userId) => {
  const { Items } = await docClient.send(
    new QueryCommand({
      TableName: process.env.CHATS_TABLE_NAME,
      KeyConditionExpression: "PK = :pk and begins_with(SK, :sk)",
      ExpressionAttributeValues: { ":pk": `USER#${userId}`, ":sk": "CHAT#" },
    })
  );
  return Items || [];
};

const getMessagesFromDb = async (chatId) => {
  const { Items } = await docClient.send(
    new QueryCommand({
      TableName: process.env.CHATS_TABLE_NAME,
      KeyConditionExpression: "PK = :pk and begins_with(SK, :sk)",
      ExpressionAttributeValues: { ":pk": `CHAT#${chatId}`, ":sk": "MESSAGE#" },
    })
  );
  return Items || [];
};

export const handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  const method = event?.requestContext?.http?.method || event?.httpMethod || "";

  const routeKey =
    event?.requestContext?.routeKey ||
    (method && event?.resource ? `${method} ${event.resource}` : "");

  const pathParams = event?.pathParameters || {};

  if (method === "OPTIONS") {
    return { statusCode: 204, headers: CORS_HEADERS, body: "" };
  }

  if (method !== "GET") {
    return {
      statusCode: 405,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: "Method Not Allowed" }),
    };
  }

  const table = process.env.CHATS_TABLE_NAME;
  if (!table) {
    console.error("CONFIG_ERROR: CHATS_TABLE_NAME missing");
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: "Server misconfigured (table)" }),
    };
  }

  try {
    if (
      routeKey === "GET /chats/{userId}" ||
      event?.resource === "/chats/{userId}"
    ) {
      const userId = pathParams.userId;
      if (!userId) {
        return {
          statusCode: 400,
          headers: CORS_HEADERS,
          body: JSON.stringify({ error: "userId is required" }),
        };
      }
      const chats = await getChatsFromDb(userId);
      return {
        statusCode: 200,
        headers: CORS_HEADERS,
        body: JSON.stringify(chats),
      };
    }

    if (
      routeKey === "GET /chats/{chatId}/messages" ||
      event?.resource === "/chats/{chatId}/messages"
    ) {
      const chatId = pathParams.chatId;
      if (!chatId) {
        return {
          statusCode: 400,
          headers: CORS_HEADERS,
          body: JSON.stringify({ error: "chatId is required" }),
        };
      }
      const messages = await getMessagesFromDb(chatId);
      return {
        statusCode: 200,
        headers: CORS_HEADERS,
        body: JSON.stringify(messages),
      };
    }

    const path = event?.path || event?.rawPath || "";
    if (path.startsWith("/chats/") && !path.endsWith("/messages")) {
      const userId = path.split("/")[2];
      const chats = await getChatsFromDb(userId);
      return {
        statusCode: 200,
        headers: CORS_HEADERS,
        body: JSON.stringify(chats),
      };
    }
    if (path.startsWith("/chats/") && path.endsWith("/messages")) {
      const segments = path.split("/");
      const chatId = segments[2];
      const messages = await getMessagesFromDb(chatId);
      return {
        statusCode: 200,
        headers: CORS_HEADERS,
        body: JSON.stringify(messages),
      };
    }

    return {
      statusCode: 404,
      headers: CORS_HEADERS,
      body: JSON.stringify({
        error: "Route not found",
        routeKey,
        resource: event?.resource,
        path,
      }),
    };
  } catch (err) {
    console.error("Error fetching data:", err);
    return {
      statusCode: 500,
      headers: CORS_HEADERS,
      body: JSON.stringify({ error: "Failed to fetch data." }),
    };
  }
};
