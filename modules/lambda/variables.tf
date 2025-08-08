variable "project_name" { 
    type = string 
}
variable "environment" { 
    type = string 
}
variable "iam_role_arn" { 
    type = string 
}
variable "chats_table_name" { 
    type = string 
}
variable "documents_bucket_name" { 
    type = string 
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
  description = "The name of the Pinecone index."
  type        = string
}

variable "lambda_packages_bucket_name" {
  description = "The name of the S3 bucket where Lambda code is stored."
  type        = string
}