# ============================================
# TERRAFORM REMOTE STATE BACKEND
# ============================================
# Stores state in S3 (backed up, team accessible)
# Uses DynamoDB for locking (prevents concurrent modifications)
terraform {
  backend "s3" {
    bucket         = "h-game-tfstate-ola-1792606978"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "h-game-terraform-state-lock"
    encrypt        = true
  }
}