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


required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }

  tls = {
    source  = "hashicorp/tls"
    version = "~> 4.0"
  }
}


# Provider alias for us-east-1 (required for ACM certificates used by ALB)
# ACM certificates for ALB must be in us-east-1 (AWS requirement)

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
