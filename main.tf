provider "aws" {
  region = "us-east-1"
}

# Random ID for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for Lambda code
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-code-bucket-${random_id.bucket_suffix.hex}"
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "lambda_bucket_pab" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Archive Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "handler.py"
  output_path = "lambda_function_payload.zip"
}

# Upload Lambda code to S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function_payload.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/my-lambda-function"
  retention_in_days = 14
}

# Lambda function
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-lambda-function"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_code.key

  handler = "handler.handler"
  runtime = "python3.11"

  role = aws_iam_role.iam_for_lambda.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# IAM role for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam-for-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda basic execution
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      }
    ]
  })
}

# Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
