# # ## API Gateway Resources

# resource "aws_api_gateway_account" "api_gateway_account" {
#  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
# }

# resource "aws_api_gateway_rest_api" "api_gateway" {
#   name                     = "${var.app_name}-api"
#   description              = "API Gateway for ${var.app_name}"
#   binary_media_types       = ["multipart/form-data"]
#   minimum_compression_size = 5242880
#   tags                     = merge(local.standard_tags, tomap({"name" = "${var.app_name}-api-gateway"}))

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_domain_name" "api_gateway_domain" {
#   domain_name              = local.domain_name
#   regional_certificate_arn = aws_acm_certificate.web_app.arn
#   security_policy          = "TLS_1_2"
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
#   tags = {
#     Name = "apig-domain-name"
#   }
# }

# resource "aws_api_gateway_base_path_mapping" "api_mapping" {
#   api_id      = aws_api_gateway_rest_api.api_gateway.id
#   domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
#   stage_name  = aws_api_gateway_stage.api_stage.stage_name
# }

# ## Stage and Deployment of API Gateway
# resource "aws_api_gateway_stage" "api_stage" {
#  stage_name    = "dev"
#  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
#  deployment_id = aws_api_gateway_deployment.api_deploy.id
#  tags          = merge(local.standard_tags, tomap({"name" = "dev"}))

#  access_log_settings {
#    destination_arn = aws_cloudwatch_log_group.api_log_group.arn
#    format          = "$context.identity.sourceIp $context.identity.caller  $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId $context.extendedRequestId"
#  }
# }

# resource "aws_api_gateway_deployment" "api_deploy" {
#  variables = {
#   integrations =  "Deployed at: ${timestamp()}"
#  }
#  triggers    = {
# 		redeployment = sha1(jsonencode([timestamp()]))
# 	}
#  rest_api_id        = aws_api_gateway_rest_api.api_gateway.id
#  stage_description  = "Dev Deployed at: ${timestamp()}" // forces to 'create' a new deployment each run
#  description        = "Deployed at ${timestamp()}"
#  lifecycle {
#    create_before_destroy = true
#  }
#   depends_on = [
#     aws_api_gateway_resource.wrapped_resource,
#     module.get_wrapped_endpoint,
#     module.post_wrapped_endpoint,
#     module.put_wrapped_endpoint
#   ]
# }

# # Enable Logging
# resource "aws_api_gateway_method_settings" "api_gateway_method_setting" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   stage_name  = aws_api_gateway_stage.api_stage.stage_name
#   method_path = "*/*"

#   settings {
#     # Enable CloudWatch logging and metrics
#     metrics_enabled        = true
#     data_trace_enabled     = true
#     logging_level          = "INFO"

#     # Limit the rate of calls to prevent abuse and unwanted charges
#     throttling_rate_limit  = 100
#     throttling_burst_limit = 50
#   }

#   depends_on = [aws_api_gateway_stage.api_stage]
# }


# #*************************
# # Gateway Responses
# #*************************

# resource "aws_api_gateway_gateway_response" "api_server_error_response" {
#   status_code   = "500"
#   response_type = "DEFAULT_5XX"
#   response_templates = {
#     "application/json" = "{\"message\": \"$context.error.validationErrorString\"}"
#   }
#   # CORS
#   response_parameters = {
#     "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
#   }

#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
# }

# #**********************
# # WRAPPED
# # /wrapped
# #**********************

# resource "aws_api_gateway_resource" "wrapped_resource" {
#   path_part   = "wrapped"
#   parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
# }

# # GET /wrapped/data
# module "get_wrapped_endpoint" {
#   source                  = "./modules/api_gateway"
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
#   parent_resource_id      = aws_api_gateway_resource.wrapped_resource.id
#   path_part               = "data"
#   http_method             = "GET"
#   allow_methods           = ["GET", "OPTIONS"]
#   allow_headers           = local.api_allow_headers
#   integration_type        = "AWS_PROXY"
#   integration_http_method = "POST"
#   uri                     = aws_lambda_function.wrapped.invoke_arn
#   authorization           = "CUSTOM"
#   authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
#   standard_tags           = local.standard_tags
#   allow_origin            = "*"
# }

# # POST /wrapped/data
# module "post_wrapped_endpoint" {
#   source                  = "./modules/api_gateway"
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
#   parent_resource_id      = module.get_wrapped_endpoint.api_gateway_resource_id
#   modify_api_resource     = true
#   http_method             = "POST"
#   allow_methods           = ["POST"]
#   allow_headers           = local.api_allow_headers
#   integration_type        = "AWS_PROXY"
#   integration_http_method = "POST"
#   uri                     = aws_lambda_function.wrapped.invoke_arn
#   authorization           = "CUSTOM"
#   authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
#   standard_tags           = local.standard_tags
#   allow_origin            = "*"
# }

# # PUT /wrapped/data
# module "put_wrapped_endpoint" {
#   source                  = "./modules/api_gateway"
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
#   parent_resource_id      = module.get_wrapped_endpoint.api_gateway_resource_id
#   modify_api_resource     = true
#   http_method             = "PUT"
#   allow_methods           = ["PUT"]
#   allow_headers           = local.api_allow_headers
#   integration_type        = "AWS_PROXY"
#   integration_http_method = "POST"
#   uri                     = aws_lambda_function.wrapped.invoke_arn
#   authorization           = "CUSTOM"
#   authorizer_id           = aws_api_gateway_authorizer.lambda_authorizer.id
#   standard_tags           = local.standard_tags
#   allow_origin            = "*"
# }

# # AWS Permissions /wrapped
# resource "aws_lambda_permission" "wrapped_data_post_permission"{
#   statement_id  = "AllowPostWrappedData"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.wrapped.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/${aws_api_gateway_resource.wrapped_resource.path_part}/data"
# }

# resource "aws_lambda_permission" "wrapped_data_get_permission"{
#   statement_id  = "AllowGetWrappedData"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.wrapped.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/GET/${aws_api_gateway_resource.wrapped_resource.path_part}/data"
# }

# resource "aws_lambda_permission" "wrapped_data_put_permission"{
#   statement_id  = "AllowPutWrappedData"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.wrapped.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/PUT/${aws_api_gateway_resource.wrapped_resource.path_part}/data"
# }
