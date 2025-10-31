# ⚙️ AI Chatbot Portfolio — Backend

This repository contains the **serverless backend** for the [AI Chatbot Portfolio](https://github.com/angelvazz/ai-chatbot-portfolio).  
It provides the API layer that powers the chatbot interface, running on **AWS Lambda** and managed entirely with **Terraform**.

---

## 🚀 Overview

The backend exposes a RESTful API endpoint that receives user messages from the frontend and returns AI-generated responses.  
It’s built for scalability, low maintenance, and cost efficiency using a **fully serverless architecture**.

### 🌐 Related Repositories

- 🖥️ **Frontend:** [ai-chatbot-portfolio](https://github.com/angelvazz/ai-chatbot-portfolio)  
  Built with Next.js, TypeScript, and TailwindCSS.

---

## 🧰 Tech Stack

| Layer          | Technology                               |
| -------------- | ---------------------------------------- |
| Runtime        | Node.js (AWS Lambda)                     |
| IaC            | Terraform                                |
| Cloud Provider | AWS                                      |
| Services       | Lambda, API Gateway, (optional) DynamoDB |
| Language       | JavaScript                               |
| Monitoring     | CloudWatch                               |
| Deployment     | Terraform CLI                            |

---

## 🧩 Architecture

[Frontend App]
|
v
[API Gateway] ← HTTPS endpoint
|
v
[AWS Lambda: chat_service]
|
v
[LLM Provider / AI API]

- **API Gateway** handles HTTP requests from the frontend.
- **Lambda Function (`chat_service`)** executes Node.js code that processes input and calls the AI model.
- **Terraform** manages the full stack — from provisioning to outputs.

---

## 🗂️ Project Structure

.
├── services/
│ └── chat_service/
│ ├── index.js # Lambda handler
│ ├── package.json # Dependencies
│ └── utils/ # Optional helpers
├── main.tf # Infrastructure definition
├── variables.tf # Input variables
├── outputs.tf # Output (API URL, Lambda ARN)
└── README.md

---

## 🧠 How It Works

1. **Frontend sends** a message to `/chat` via POST request.
2. **Lambda receives** the payload, validates it, and processes the input.
3. **Lambda calls** the external AI provider (like OpenAI or Anthropic) using `OPENAI_API_KEY`.
4. **Lambda responds** with the AI-generated text.
5. **API Gateway** sends the response back to the frontend.

---

## ⚙️ Setup and Deployment

### 1️⃣ Prerequisites

- AWS account configured with proper credentials
- Terraform installed (v1.5+ recommended)
- Node.js v18+ installed locally

### 2️⃣ Environment Variables

Before deploying, create a `.env` file or export these variables:

```bash
OPENAI_API_KEY=your_openai_api_key
REGION=us-north-3000
STAGE=prod
```
