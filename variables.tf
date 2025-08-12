variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "ai-chatbot"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-2"
}
variable "aws_profile" {
  description = "The AWS profile."
  type        = string
  default     = "default"
}

variable "openai_api_key_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for the OpenAI API Key."
  type        = string
}

variable "pinecone_api_key_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret for the Pinecone API Key."
  type        = string
}

variable "pinecone_index_name" {
  description = "The name of the Pinecone index to use."
  type        = string
}