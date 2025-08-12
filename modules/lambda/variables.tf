variable "function_name" {
  type        = string
  description = "The name of the lambda function (without project/env prefix)."
}

variable "source_path" {
  type        = string
  description = "Path to the Lambda's source code directory."
}

variable "project_name" {
  type        = string
  description = "The name of the project."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., 'dev', 'prod')."
}

variable "lambda_packages_s3_bucket" {
  type        = string
  description = "The name of the S3 bucket to store Lambda packages."
}

variable "iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role for Lambda execution."
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = "index.handler"
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function."
  default     = "nodejs20.x"
}

variable "timeout" {
  type        = number
  description = "The amount of time that Lambda allows a function to run before stopping it."
  default     = 30
}

variable "memory_size" {
  type        = number
  description = "The amount of memory that your function has access to."
  default     = 256
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables for the function."
  default     = {}
}
