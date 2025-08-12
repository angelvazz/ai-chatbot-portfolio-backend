variable "api_name" {
  description = "The name for the API Gateway."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "get_chats_lambda_arn" {
  description = "ARN of the Get Chats Lambda function."
  type        = string
}

variable "post_message_lambda_arn" {
  description = "ARN of the Post Message Lambda function."
  type        = string
}
