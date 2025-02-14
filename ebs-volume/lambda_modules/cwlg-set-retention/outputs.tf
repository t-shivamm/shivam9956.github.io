output "lambda_info" {
  value = {
    name = aws_lambda_function.lambda.function_name
    arn  = aws_lambda_function.lambda.arn
  }
}
