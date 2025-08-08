data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.project_name}-lambda-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_custom_permissions" {
  statement {
    sid    = "AllowS3Read"
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"] 
  }

  statement {
    sid    = "AllowDynamoDBActions"
    actions = [
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]
    resources = [var.dynamodb_table_arn]
  }

  statement {
    sid    = "AllowSecretsManagerRead"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name        = "${var.project_name}-lambda-custom-policy-${var.environment}"
  description = "Custom permissions for the chatbot Lambda functions."
  policy      = data.aws_iam_policy_document.lambda_custom_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_custom_permissions" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}