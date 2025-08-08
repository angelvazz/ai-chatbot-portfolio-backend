resource "random_id" "bucket_suffix" { byte_length = 8 }

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
  tags = {
    Name        = "${var.bucket_prefix}-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "documents_bucket_pab" {
  bucket = aws_s3_bucket.documents_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "lambda_packages_bucket" {
  bucket = "${var.bucket_prefix}-lambda-packages-${random_id.bucket_suffix.hex}"
  tags = {
    Name        = "${var.bucket_prefix}-lambda-packages"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_packages_pab" {
  bucket = aws_s3_bucket.lambda_packages_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}