variable "project_name" { 
    type = string 
}
variable "environment" { 
    type = string 
}
variable "aws_region" {
     type = string 
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for documents."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for chats."
  type        = string
}