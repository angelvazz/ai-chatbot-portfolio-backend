resource "aws_apigatewayv2_api" "main" {
  name          = var.api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["http://localhost:3000", "https://angelvazz.github.io"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "get_chats" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.get_chats_lambda_arn
}

resource "aws_apigatewayv2_integration" "post_message" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.post_message_lambda_arn
}

resource "aws_apigatewayv2_route" "chat_post" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.post_message.id}"
  depends_on = [aws_apigatewayv2_integration.post_message]
}

resource "aws_apigatewayv2_route" "chats_get" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /chats/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.get_chats.id}"
  depends_on = [aws_apigatewayv2_integration.get_chats]
}

resource "aws_apigatewayv2_route" "messages_get" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /chats/{chatId}/messages"
  target    = "integrations/${aws_apigatewayv2_integration.get_chats.id}"
  depends_on = [aws_apigatewayv2_integration.get_chats]
}

resource "aws_lambda_permission" "api_gateway_get" {
  statement_id  = "AllowAPIGatewayInvokeGetChats"
  action        = "lambda:InvokeFunction"
  function_name = var.get_chats_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_post" {
  statement_id  = "AllowAPIGatewayInvokePostMessage"
  action        = "lambda:InvokeFunction"
  function_name = var.post_message_lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}