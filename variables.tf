
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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, dev)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "development", "staging", "production", "prod"], var.environment)
    error_message = "Environment must be dev, development, staging, production, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "h-game"
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per availability zone)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per availability zone)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "internet_route_cidr" {
  description = "CIDR block for internet route (typically 0.0.0.0/0 for all traffic)"
  type        = string
  default     = "0.0.0.0/0"
}


# ============================================
# SECURITY & NAT VARIABLES
# ============================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways (1 for cost savings, 3 for high availability)"
  type        = number
  default     = 1 # Single NAT saves approximately $22/month vs 3 NATs
}

variable "backend_port" {
  description = "Backend application port"
  type        = number
  default     = 3001
}

variable "postgres_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Redis cache port"
  type        = number
  default     = 6379
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

# ============================================
# EKS CLUSTER VARIABLES
# ============================================

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "h-game-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "enable_cluster_logging" {
  description = "Enable EKS cluster logging to CloudWatch"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}


# ============================================
# EKS NODE VARIABLES
# ============================================

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"

  validation {
    condition = can(regex(
      "^t3\\.(micro|small|medium|large)$",
      var.eks_node_instance_type
    ))

    error_message = "Instance type must be t3.micro, t3.small, t3.medium, or t3.large."
  }
}

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition = (
      var.eks_node_desired_size >= 1 &&
      var.eks_node_desired_size <= 10
    )

    error_message = "Desired size must be between 1 and 10 nodes."
  }
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.eks_node_min_size >= 1
    error_message = "Minimum size must be at least 1 node."
  }
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4

  validation {
    condition = (
      var.eks_node_max_size >= var.eks_node_min_size &&
      var.eks_node_max_size <= 20
    )

    error_message = "Maximum size must be >= min_size and <= 20 nodes."
  }
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "h-game-nodes"
}

variable "node_capacity_type" {
  description = "EKS node capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "SPOT"

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.node_capacity_type
    )

    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}
