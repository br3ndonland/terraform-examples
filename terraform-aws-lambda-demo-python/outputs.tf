# Output value definitions

output "lambda_bucket_name" {
  description = "S3 bucket used to store Lambda function archive"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "AWS Lambda function name"
  value       = aws_lambda_function.hello_world.function_name
}

output "base_url" {
  description = "API Gateway base URL"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}
