
# ============================================
# RDS POSTGRESQL (Managed Database)
# ============================================
# AWS managed PostgreSQL.
# Replaces: PostgreSQL StatefulSet (from K2).

# ============================================
# DB SUBNET GROUP
# ============================================
# Tells RDS which subnets to use.
# RDS requires subnets in multiple Availability Zones.

resource "aws_db_subnet_group" "main" {
  name = "${local.name_prefix}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id, # Private subnet 1 (us-east-1a)
    aws_subnet.private_2.id, # Private subnet 2 (us-east-1b)
    aws_subnet.private_3.id, # Private subnet 3 (us-east-1c)
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-subnet-group"
      Task = "T5"
    }
  )
}

# ============================================
# OUTPUT: SUBNET GROUP NAME
# ============================================

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}


# ============================================
# DB PARAMETER GROUP
# ============================================
# Custom database configuration.
# Allows you to tune PostgreSQL settings.

resource "aws_db_parameter_group" "postgres" {
  family = "postgres18" # PostgreSQL 15 family
  name   = "${local.name_prefix}-postgres-params"

  # Example parameters (optional - defaults work fine)
  # parameter {
  #   name  = "max_connections"
  #   value = "100"
  # }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-postgres-params"
      Task = "T5"
    }
  )
}


# ============================================
# RDS POSTGRESQL INSTANCE
# ============================================
# Managed PostgreSQL database.
# AWS handles: Backups, updates, monitoring.

resource "aws_db_instance" "postgres" {
  # Basic configuration
  identifier     = var.rds_db_identifier
  engine         = "postgres"
  # engine_version = "15.4"
  instance_class = var.rds_instance_class

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password
  port     = var.rds_port

  # Password is stored in terraform.tfvars (not committed to Git).
  # In production, use AWS Secrets Manager.

  # ============================================
  # LIFECYCLE RULES
  # ============================================

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false

    # Note: create_before_destroy cannot be used with RDS.
  }

  # Lifecycle Rules Explained:
  # - prevent_destroy = false: Allows Terraform to destroy the resource.
  # - Production: Consider setting this to true.
  # - ignore_changes = [password]: Terraform ignores password changes
  #   made through this variable after initial creation.

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  # Parameter group
  parameter_group_name = aws_db_parameter_group.postgres.name

  # Dependencies: Ensure networking and parameter group are ready
  depends_on = [
    aws_db_subnet_group.main,
    aws_db_parameter_group.postgres,
    aws_security_group.database,
  ]

  # Backup configuration
  #backup_retention_period = 7
  #backup_window           = "03:00-04:00"
  #maintenance_window      = "mon:04:00-mon:05:00"

  # Multi-AZ (for high availability)
  # Skip for learning (saves costs).
  # multi_az = true # Uncomment for production

  # Deletion protection
  deletion_protection = false

  # Skip final snapshot for learning
  skip_final_snapshot = true

  # Tags
  tags = merge(
    local.common_tags,
    {
      Name = var.rds_db_identifier
      Task = "T5"
    }
  )
}

# ============================================
# OUTPUTS
# ============================================

# Output: RDS endpoint (connection string)
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

# Output: RDS address (hostname for connection)
output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgres.address
}

# Output: RDS port
output "rds_port" {
  description = "RDS instance port"
  value       = var.rds_port
}
