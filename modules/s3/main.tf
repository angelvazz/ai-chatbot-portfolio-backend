resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket        = "${var.bucket_prefix}-documents-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.bucket_prefix}-documents-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "documents_ownership" {
  bucket = aws_s3_bucket.documents_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "documents_bucket_pab" {
  bucket                  = aws_s3_bucket.documents_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documents_sse" {
  bucket = aws_s3_bucket.documents_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket" "lambda_packages_bucket" {
  bucket        = "${var.bucket_prefix}-lambda-packages-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.bucket_prefix}-lambda-packages"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "lambda_packages_ownership" {
  bucket = aws_s3_bucket.lambda_packages_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_packages_pab" {
  bucket                  = aws_s3_bucket.lambda_packages_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_packages_sse" {
  bucket = aws_s3_bucket.lambda_packages_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}