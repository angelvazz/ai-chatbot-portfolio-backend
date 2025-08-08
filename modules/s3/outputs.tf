output "bucket_name" {
  description = "The name of the S3 bucket for user documents."
  value       = aws_s3_bucket.documents_bucket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket for user documents."
  value       = aws_s3_bucket.documents_bucket.arn
}

output "lambda_packages_bucket_name" {
  description = "The name of the S3 bucket for Lambda function packages."
  value       = aws_s3_bucket.lambda_packages_bucket.bucket
}
