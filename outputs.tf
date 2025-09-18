# Outputs for testing and verification

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.my_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.my_lambda.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket storing Lambda code"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "test_command" {
  description = "Command to test the Lambda function"
  value       = "aws lambda invoke --function-name ${aws_lambda_function.my_lambda.function_name} response.json && cat response.json"
}