
# ============================================
# VPC (Virtual Private Cloud)
# ============================================
# Your private network in AWS
# Like your home network (192.168.x.x) but in the cloud

resource "aws_vpc" "main" {
  # CIDR block: IP address range for your network
  # Uses variable instead of hardcoded value
  cidr_block = var.vpc_cidr

  # Enable DNS hostnames (required for EKS)
  # Allows resources to have DNS names
  enable_dns_hostnames = true

  # Enable DNS resolution (required for EKS)
  # Allows resources to resolve DNS names
  enable_dns_support = true

  # Tags: Labels for organization (uses locals for common tags)
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
      Task = "T1"
    }
  )
}

# Output: VPC ID (needed for other resources)
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Output: VPC CIDR block (for reference)
output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}


# ============================================
# INTERNET GATEWAY
# ============================================
# Connects your VPC to the internet
# Like your home router's internet connection

resource "aws_internet_gateway" "main" {
  # Attach to the VPC we just created
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
      Task = "T1"
    }
  )
}

# Output: Internet Gateway ID
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
