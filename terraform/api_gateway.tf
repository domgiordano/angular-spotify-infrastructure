# API Gateway REST API
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.app_name}-api"
  description = "API GW for ${var.app_name}"
}
