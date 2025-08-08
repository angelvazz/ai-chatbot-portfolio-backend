terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"
}


module "iam_roles" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  s3_bucket_arn      = module.s3_documents_bucket.bucket_arn
  dynamodb_table_arn = module.dynamodb_chats_table.table_arn
}

module "s3_documents_bucket" {
  source        = "./modules/s3"
  bucket_prefix = "${var.project_name}-documents"
  environment   = var.environment
}

module "dynamodb_chats_table" {
  source      = "./modules/dynamodb"
  table_name  = "${var.project_name}-chats-${var.environment}"
  environment = var.environment
}

module "cognito_user_pool" {
  source      = "./modules/cognito"
  pool_name   = "${var.project_name}-user-pool-${var.environment}"
  environment = var.environment
}

module "lambda_functions" {
  source                      = "./modules/lambda"
  project_name                = var.project_name
  environment                 = var.environment
  iam_role_arn                = module.iam_roles.lambda_execution_role_arn
  chats_table_name            = module.dynamodb_chats_table.table_name
  documents_bucket_name       = module.s3_documents_bucket.bucket_name
  lambda_packages_bucket_name = module.s3_documents_bucket.lambda_packages_bucket_name
  openai_api_key_secret_arn   = var.openai_api_key_secret_arn
  pinecone_api_key_secret_arn = var.pinecone_api_key_secret_arn
  pinecone_index_name         = var.pinecone_index_name
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  api_name            = "${var.project_name}-api-${var.environment}"
  lambda_function_arn = module.lambda_functions.chat_handler_lambda_arn
  environment         = var.environment
}

module "eventbridge_rule" {
  source                  = "./modules/eventbridge"
  project_name            = var.project_name
  environment             = var.environment
  s3_bucket_arn           = module.s3_documents_bucket.bucket_arn
  process_lambda_arn      = module.lambda_functions.process_document_lambda_arn
}