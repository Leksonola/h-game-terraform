
# ============================================
# SECURITY GROUPS
# ============================================
# Firewall rules that control traffic
# Default: Deny all (nothing gets through)
# Rules: Allow specific traffic only


# ============================================
# ALB (Application Load Balancer) Security Group
# ============================================
# Allows internet traffic to reach Load Balancer

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: Allow HTTP from internet
  ingress {
    description = "HTTP from internet"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress Rule: Allow HTTPS from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow all (ALB needs to forward to backend)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
      Task = "T2"
    }
  )
}


# ============================================
# Backend Security Group
# ============================================
# Allows ALB to reach backend, backend to reach database/cache

resource "aws_security_group" "backend" {
  name        = "${local.name_prefix}-backend-sg"
  description = "Security group for backend Pods"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: Allow HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress: Allow all (backend needs to reach database, cache, internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-backend-sg"
      Task = "T2"
    }
  )
}


# ============================================
# Database Security Group
# ============================================
# Allows backend to reach database, nothing else

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: Allow PostgreSQL from backend only
  ingress {
    description     = "PostgreSQL from backend"
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  # Egress: Allow all (database needs to respond)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database-sg"
      Task = "T2"
    }
  )
}


# ============================================
# Cache Security Group
# ============================================
# Allows backend to reach cache, nothing else

resource "aws_security_group" "cache" {
  name        = "${local.name_prefix}-cache-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.main.id

  # Ingress Rule: Allow Redis from backend only
  ingress {
    description     = "Redis from backend"
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  # Egress: Allow all (cache needs to respond)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cache-sg"
      Task = "T2"
    }
  )
}


# ============================================
# EKS Cluster Security Group
# ============================================
# Allows cluster communication

resource "aws_security_group" "eks_cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow cluster communication (will be configured by EKS)
  # EKS will add its own rules automatically

  # Egress: Allow all (cluster needs to communicate)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-sg"
      Task = "T2"
    }
  )
}


# ============================================
# EKS Node Group Security Group
# ============================================
# Allows worker nodes to communicate

resource "aws_security_group" "eks_nodes" {
  name        = "${local.name_prefix}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow from cluster and other nodes
  ingress {
    description     = "From cluster"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description = "From nodes"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Egress: Allow all (nodes need to pull images, communicate)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-nodes-sg"
      Task = "T2"
    }
  )
}


# ============================================
# OUTPUTS: SECURITY GROUP IDS
# ============================================

output "alb_security_group_id" {
  description = "ID of ALB security group"
  value       = aws_security_group.alb.id
}

output "backend_security_group_id" {
  description = "ID of backend security group"
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "ID of database security group"
  value       = aws_security_group.database.id
}

output "cache_security_group_id" {
  description = "ID of cache security group"
  value       = aws_security_group.cache.id
}
