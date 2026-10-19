# ============================================
# TERRAFORM VARIABLES
# ============================================
# Variables make your code reusable and configurable.
# Values can be set in terraform.tfvars.

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for S3 bucket name (must be globally unique)"
  type        = string
  default     = "h-game-terraform-learning"
}

variable "environment" {
  description = "Environment name (e.g., learning, dev, production)"
  type        = string
  default     = "learning"
}