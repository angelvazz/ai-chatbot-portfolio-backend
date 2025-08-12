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
  profile = var.aws_profile
}


module "s3_buckets" {
  source        = "./modules/s3"
  bucket_prefix = var.project_name
  environment   = var.environment
}

module "iam_roles" {
  source             = "./modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  s3_bucket_arn      = module.s3_buckets.bucket_arn
  dynamodb_table_arn = module.dynamodb_chats_table.table_arn
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

module "chat_service" {
  source = "./services/chat_service" 
  project_name                = var.project_name
  environment                 = var.environment
  iam_role_arn                = module.iam_roles.lambda_execution_role_arn
  lambda_packages_s3_bucket   = module.s3_buckets.lambda_packages_bucket_name
  chats_table_name            = module.dynamodb_chats_table.table_name
  documents_bucket_name       = module.s3_buckets.bucket_name
  openai_api_key_secret_arn   = var.openai_api_key_secret_arn
  pinecone_api_key_secret_arn = var.pinecone_api_key_secret_arn
  pinecone_index_name         = var.pinecone_index_name
}

module "api_gateway" {
  source                  = "./modules/api_gateway"
  api_name                = "${var.project_name}-api-${var.environment}"
  environment             = var.environment
  get_chats_lambda_arn    = module.chat_service.get_chats_lambda_arn
  post_message_lambda_arn = module.chat_service.post_message_lambda_arn
}

module "eventbridge_rule" {
  source                  = "./modules/eventbridge"
  project_name            = var.project_name
  environment             = var.environment
  s3_bucket_arn           = module.s3_buckets.bucket_arn
  process_lambda_arn      = module.chat_service.process_document_lambda_arn
}