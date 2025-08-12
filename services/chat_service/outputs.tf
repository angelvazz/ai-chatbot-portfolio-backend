output "get_chats_lambda_arn" {
  value = module.lambda_get_chats.lambda_arn
}

output "post_message_lambda_arn" {
  value = module.lambda_post_message.lambda_arn
}

output "process_document_lambda_arn" {
  value = module.lambda_process_document.lambda_arn
}