resource "aws_dynamodb_table" "chats_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ChatID"
  attribute {
    name = "ChatID"
    type = "S"
  }
  tags = {
    Name        = var.table_name
    Environment = var.environment
  }
}