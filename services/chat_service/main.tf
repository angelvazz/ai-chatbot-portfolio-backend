module "lambda_get_chats" {
  source                    = "../../modules/lambda"
  project_name              = var.project_name
  environment               = var.environment
  function_name             = "get-chats"
  iam_role_arn              = var.iam_role_arn
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket

  source_path = "${path.module}/lambdas/get-chats"

  runtime      = "nodejs20.x"
  handler      = "index.handler"
  timeout      = 30
  memory_size  = 512
  environment_variables = {
    CHATS_TABLE_NAME            = var.chats_table_name
  }
}

module "lambda_post_message" {
  source                    = "../../modules/lambda"
  project_name              = var.project_name
  environment               = var.environment
  function_name             = "post-message"
  iam_role_arn              = var.iam_role_arn
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket

  source_path = "${path.module}/lambdas/post-message"

  timeout     = 60
  memory_size = 1024
  environment_variables = {
    CHATS_TABLE_NAME             = var.chats_table_name
    OPENAI_API_KEY_SECRET_ARN    = var.openai_api_key_secret_arn
    PINECONE_API_KEY_SECRET_ARN  = var.pinecone_api_key_secret_arn
    PINECONE_INDEX_NAME          = var.pinecone_index_name
  }
}

module "lambda_process_document" {
  source                    = "../../modules/lambda"
  project_name              = var.project_name
  environment               = var.environment
  function_name             = "process-document"
  iam_role_arn              = var.iam_role_arn
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket

  source_path = "${path.module}/lambdas/process-document"

  timeout     = 120
  memory_size = 1536
  environment_variables = {
    OPENAI_API_KEY_SECRET_ARN    = var.openai_api_key_secret_arn
    PINECONE_API_KEY_SECRET_ARN  = var.pinecone_api_key_secret_arn
    PINECONE_INDEX_NAME          = var.pinecone_index_name
  }
}