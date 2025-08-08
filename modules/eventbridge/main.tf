resource "aws_cloudwatch_event_rule" "s3_upload_rule" {
  name        = "${var.project_name}-s3-upload-rule-${var.environment}"
  description = "Trigger on S3 object creation"
  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        arn = [var.s3_bucket_arn]
      }
    }
  })
}
resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.s3_upload_rule.name
  arn  = var.process_lambda_arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.process_lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_upload_rule.arn
}