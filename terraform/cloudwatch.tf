
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
