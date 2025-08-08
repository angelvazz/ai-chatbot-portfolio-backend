data "archive_file" "chat_handler_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../services/chat-handler"
  output_path = "${path.module}/chat_handler.zip"
}

data "archive_file" "process_document_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../services/process-document" 
  output_path = "${path.module}/process_document.zip"
}

resource "aws_s3_object" "chat_handler_lambda_code" {
  bucket = var.lambda_packages_bucket_name
  key    = "chat-handler/${data.archive_file.chat_handler_zip.output_md5}.zip"
  source = data.archive_file.chat_handler_zip.output_path
}

resource "aws_s3_object" "process_document_lambda_code" {
  bucket = var.lambda_packages_bucket_name
  key    = "process-document/${data.archive_file.process_document_zip.output_md5}.zip"
  source = data.archive_file.process_document_zip.output_path
}

resource "aws_lambda_function" "chat_handler" {
  function_name    = "${var.project_name}-chat-handler-${var.environment}"
  s3_bucket        = aws_s3_object.chat_handler_lambda_code.bucket
  s3_key           = aws_s3_object.chat_handler_lambda_code.key
  source_code_hash = data.archive_file.chat_handler_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = var.iam_role_arn
  timeout          = 30

  environment {
    variables = {
      CHATS_TABLE_NAME         = var.chats_table_name
      OPENAI_API_KEY_SECRET_ARN = var.openai_api_key_secret_arn
      PINECONE_API_KEY_SECRET_ARN = var.pinecone_api_key_secret_arn
      PINECONE_INDEX_NAME      = var.pinecone_index_name
    }
  }
}

resource "aws_lambda_function" "process_document" {
  function_name    = "${var.project_name}-process-document-${var.environment}"
  s3_bucket        = aws_s3_object.process_document_lambda_code.bucket
  s3_key           = aws_s3_object.process_document_lambda_code.key
  source_code_hash = data.archive_file.process_document_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = var.iam_role_arn
  timeout          = 90
  memory_size      = 512

  environment {
    variables = {
      DOCUMENTS_BUCKET_NAME     = var.documents_bucket_name
      OPENAI_API_KEY_SECRET_ARN = var.openai_api_key_secret_arn
      PINECONE_API_KEY_SECRET_ARN = var.pinecone_api_key_secret_arn
      PINECONE_INDEX_NAME      = var.pinecone_index_name
    }
  }
}
