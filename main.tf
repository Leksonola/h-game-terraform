# ============================================
# TERRAFORM CONFIGURATION
# ============================================
# This file defines what infrastructure to create

# Provider: Tells Terraform which cloud to use
provider "aws" {
  region = "us-east-1" # AWS region (change to your preferred region)
  # Credentials come from AWS CLI or environment variables
}

# Resource: An S3 bucket (simple storage)
# This is your FIRST Terraform resource!
resource "aws_s3_bucket" "my_first_bucket" {
  # Bucket name must be globally unique
  # Using timestamp to ensure uniqueness
  bucket = "${var.bucket_name_prefix}-${var.aws_region}"

  # Tags: Labels for organization
  tags = {
    Name        = "My First Terraform Bucket"
    Environment = "learning"
    CreatedBy   = "Terraform"
    Task        = "T0"
  }
}

# Output: Value to display after creation
output "bucket_name" {
  description = "Name of the S3 bucket we created"
  value       = aws_s3_bucket.my_first_bucket.bucket
}

output "bucket_arn" {
  description = "ARN (Amazon Resource Name) of the bucket"
  value       = aws_s3_bucket.my_first_bucket.arn
}