resource "aws_lambda_function" "authentication" {

  function_name     = "${var.app_name}-authentication"
  filename          = "./templates/lambda_stub.zip"
  source_code_hash  = filebase64sha256("./templates/lambda_stub.zip")
  handler           = "handler.handler"
  layers            = [aws_lambda_layer_version.lambda_layer.arn]
  runtime           = var.lambda_runtime
  memory_size       = 1024
  timeout           = 900
  role              = aws_iam_role.lambda_role.arn
  environment {
    variables = local.lambda_variables
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.private_subnet.ids
    security_group_ids = [data.aws_security_group.managed-lambda-sg.id]
  }

  tags = merge(local.standard_tags, tomap({"name" = "${var.app_name}-authentication"}))



  tracing_config {
    mode = var.lambda_trace_mode
  }



  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash,
      source_code_size,
      layers
    ]
  }

  depends_on = [
    aws_iam_role_policy.lambda_role_policy,
    aws_iam_role.lambda_role
  ]
}
