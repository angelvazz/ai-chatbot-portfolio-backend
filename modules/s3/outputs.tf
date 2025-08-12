output "bucket_name" {
  value = aws_s3_bucket.documents_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.documents_bucket.arn
}

output "lambda_packages_bucket_name" {
  value = aws_s3_bucket.lambda_packages_bucket.bucket
}

output "lambda_packages_bucket_arn" {
  value = aws_s3_bucket.lambda_packages_bucket.arn
}