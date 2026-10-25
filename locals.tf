locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  # Name prefix for consistent naming
  name_prefix = "${var.project_name}-${var.environment}"
}