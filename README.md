# AWS Lambda/Terraform Troubleshooting - Task 3 Solution

This project contains the fixed Terraform and AWS Lambda infrastructure for the DevOps assessment Task 3.

## Issues Identified and Fixed

### 1. S3 Bucket Configuration Issues
**Problem:** Deprecated `acl` attribute and non-unique bucket name
**Fix:**
- Removed deprecated `acl` attribute
- Added random suffix for unique bucket naming
- Implemented proper S3 security with public access blocks and versioning

### 2. Lambda Function Deployment Issues
**Problem:** Missing zip file and deprecated runtime
**Fix:**
- Added `archive_file` data source to package handler.py
- Updated Python runtime from 3.8 to 3.11 (3.8 is deprecated by AWS)
- Added proper S3 object upload for Lambda code

### 3. IAM Permission Issues
**Problem:** Missing execution policies for Lambda
**Fix:**
- Created IAM policy for CloudWatch logging permissions
- Added policy attachment to Lambda execution role
- Implemented proper least-privilege access

### 4. Missing Infrastructure Components
**Problem:** No CloudWatch logs or proper dependencies
**Fix:**
- Added CloudWatch log group for Lambda function
- Implemented proper resource dependencies
- Added backend configuration with version constraints

## Setup and Deployment

```bash
# 1. Set AWS profile
export AWS_PROFILE="your-profile-name"

# 2. Initialize and apply Terraform
terraform init
terraform plan
terraform apply

# 3. Test Lambda function
aws lambda invoke --region us-east-1 --function-name my-lambda-function response.json
cat response.json
```
