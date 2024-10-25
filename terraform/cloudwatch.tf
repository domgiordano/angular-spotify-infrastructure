
## DYNAMODB
resource "aws_cloudwatch_log_group" "wrapped_db_log_group" {
    name = aws_dynamodb_table.wrapped.id
    retention_in_days = 14
    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-wrapped"}))
}

## APIGW
resource "aws_cloudwatch_log_group" "api_log_group" {
    name = aws_api_gateway_rest_api.api_gateway.id
    retention_in_days = 14
    tags = merge(local.standard_tags, tomap({ "name"= "${var.app_name}-APIGW-Access-Logs"}))
}

## CHRON JOB - WRAPPED
resource "aws_cloudwatch_event_rule" "wrapped_schedule" {
  name        ="${var.app_name}-wrapped-schedule"
  description = "Trigger Wrapped Lambda function on the first day of every month"
  schedule_expression = "cron(0 4 1 * ? *)"  # Runs at midnight on the first day of every month
}

resource "aws_cloudwatch_event_target" "wrapped_target" {
  rule      = aws_cloudwatch_event_rule.wrapped_schedule.name
  target_id = "${var.app_name}-wrapped-target-id"
  arn       = aws_lambda_function.wrapped.arn
}
