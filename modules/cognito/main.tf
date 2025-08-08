resource "aws_cognito_user_pool" "main" {
  name = var.pool_name
  auto_verified_attributes = ["email"]
  tags = {
    Environment = var.environment
  }
}
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.pool_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = false 
}