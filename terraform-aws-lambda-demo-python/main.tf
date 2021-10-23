# HashiCorp Learn: Terraform - Deploy Serverless Applications with AWS Lambda and API Gateway
# https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws

provider "aws" {
  region = var.aws_region
}

# Use a random_pet name as bucket suffix: total length must be <63 characters
resource "random_pet" "lambda_bucket_name" {
  prefix = "hashicorp-learn-terraform"
  length = 2
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.lambda_bucket_name.id
  acl           = "private"
  force_destroy = true
}

# Create Lambda archive: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
data "archive_file" "lambda_hello_world" {
  type        = "zip"
  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

# Configure S3 bucket for Lambda archive
resource "aws_s3_bucket_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path
  etag   = filemd5(data.archive_file.lambda_hello_world.output_path)
}

# Create lambda function
resource "aws_lambda_function" "hello_world" {
  function_name    = "hashicorp-learn-terraform-lambda-api-gateway-python"
  handler          = "hello_world.hello.lambda_handler"
  runtime          = "python3.9"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_bucket_object.lambda_hello_world.key
  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}

# Create CloudWatch log group for Lambda logs
resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 30
}

# Create AWS IAM Lambda execution role and define assume role policy:
# https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
# https://www.terraform.io/docs/language/functions/jsonencode.html
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create API Gateway for Lambda
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api
resource "aws_apigatewayv2_api" "lambda" {
  name          = "lambda_apigateway"
  protocol_type = "HTTP"
}

# Create API Gateway Stage
resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = aws_lambda_function.hello_world.function_name
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# Create API Gateway integration
resource "aws_apigatewayv2_integration" "hello_world" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.hello_world.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Create API Gateway route
resource "aws_apigatewayv2_route" "hello_world" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

# Create CloudWatch group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/api_gateway/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}

# Create permission to allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
