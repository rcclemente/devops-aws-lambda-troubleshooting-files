# Backend configuration for Terraform state
# Using local backend for troubleshooting exercise
# In production, this would use S3 backend with DynamoDB locking
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

  # Local backend for this exercise
  # Use AWS profile via:
  #   export AWS_PROFILE="your-profile-name"
  #   terraform plan
  backend "local" {
    path = "terraform.tfstate"
  }
}
