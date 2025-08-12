output "api_gateway_invoke_url" {
  description = "The URL to invoke the API Gateway."
  value       = module.api_gateway.invoke_url
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = module.cognito_user_pool.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = module.cognito_user_pool.user_pool_client_id
}

output "documents_bucket_name" {
  description = "The name of the S3 bucket for storing user documents."
  value       = module.s3_buckets.bucket_name 
}
