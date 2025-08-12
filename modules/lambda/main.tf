resource "null_resource" "ensure_dist" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/dist"
  }
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.root}/dist/${var.function_name}.zip"
  excludes    = ["**/*.zip"]

  depends_on = [null_resource.ensure_dist]
}

resource "aws_s3_object" "package" {
  bucket = var.lambda_packages_s3_bucket
  key    = "lambda/${var.environment}/${var.function_name}.zip"
  source = data.archive_file.zip.output_path
  etag   = data.archive_file.zip.output_md5

  depends_on = [data.archive_file.zip]
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-${var.function_name}-${var.environment}"
  role             = var.iam_role_arn

  runtime          = var.runtime
  handler          = var.handler
  timeout          = var.timeout
  memory_size      = var.memory_size

  s3_bucket        = aws_s3_object.package.bucket
  s3_key           = aws_s3_object.package.key
  source_code_hash = data.archive_file.zip.output_base64sha256

  publish = true

  environment {
    variables = var.environment_variables
  }

  depends_on = [aws_s3_object.package]
}

