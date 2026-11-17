
# ============================================
# ECR (Elastic Container Registry)
# ============================================

# Private container registry in AWS
# Replaces: localhost:32000 (from K1-K9)

# ============================================
# ECR REPOSITORY - Backend
# ============================================

resource "aws_ecr_repository" "backend" {
  name                 = var.ecr_backend_repository
  image_tag_mutability = var.ecr_image_tag_mutability

  # Image scanning (optional - for security)
  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  # Encryption (optional - for security)
  encryption_configuration {
    encryption_type = "AES256" # AWS managed encryption
  }

  # Lifecycle policy (optional - clean up old images)
  # Automatically retain the 10 most recent images
  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep last 10 images"

          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = 10
          }

          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.ecr_backend_repository
      Task = "T8"
    }
  )
}

# ============================================
# ECR REPOSITORY - Frontend
# ============================================

resource "aws_ecr_repository" "frontend" {
  name                 = var.ecr_frontend_repository
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep last 10 images"

          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = 10
          }

          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.ecr_frontend_repository
      Task = "T8"
    }
  )
}

# ============================================
# OUTPUTS: Repository URLs
# ============================================

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

# ============================================
# OUTPUTS: Repository ARNs
# ============================================

output "ecr_backend_repository_arn" {
  description = "ARN of the backend ECR repository"
  value       = aws_ecr_repository.backend.arn
}

output "ecr_frontend_repository_arn" {
  description = "ARN of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.arn
}
