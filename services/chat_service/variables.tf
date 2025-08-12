variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'prod')."
  type        = string
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for Lambda execution."
  type        = string
}

variable "lambda_packages_s3_bucket" {
  description = "The name of the S3 bucket to store Lambda packages."
  type        = string
}

variable "chats_table_name" {
  description = "Name of the DynamoDB table for chats."
  type        = string
}

variable "documents_bucket_name" {
  description = "Name of the S3 bucket for documents."
  type        = string
}

variable "openai_api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for OpenAI API key."
  type        = string
}

variable "pinecone_api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for Pinecone API key."
  type        = string
}

variable "pinecone_index_name" {
  description = "Name of the Pinecone index."
  type        = string
}
