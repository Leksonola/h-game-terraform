# ============================================
# TERRAFORM & PROVIDER CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.aws_region # Use variable instead of hardcoded 
  # Default tags applied to all resources (unless overridden)
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}