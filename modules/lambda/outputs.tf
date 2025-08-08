output "chat_handler_lambda_arn" {
  description = "The ARN of the Chat Handler Lambda function."
  value       = aws_lambda_function.chat_handler.arn
}

output "process_document_lambda_arn" {
  description = "The ARN of the Process Document Lambda function."
  value       = aws_lambda_function.process_document.arn
}