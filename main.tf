terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-2"
  profile = "default" 
}


resource "aws_s3_bucket" "documents_bucket" {
  bucket = "angelvazz-chatbot-docs-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "ChatbotDocumentsBucket"
    Project     = "AI Chatbot Portfolio"
  }
}


resource "random_id" "bucket_suffix" {
  byte_length = 8
}


output "documents_bucket_name" {
  value       = aws_s3_bucket.documents_bucket.bucket
  description = "The name of the S3 bucket for storing user documents."
}
