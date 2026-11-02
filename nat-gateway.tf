
# ============================================
# NAT GATEWAY
# ============================================
# Allows private subnets to access internet
# Without exposing private resources directly to internet


# ============================================
# ELASTIC IP FOR NAT GATEWAY
# ============================================
# NAT Gateway needs a static public IP

resource "aws_eip" "nat" {
  # EIP must be in VPC (not EC2-Classic)
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip"
      Task = "T2"
    }
  )

  # Ensure Internet Gateway exists first
  depends_on = [aws_internet_gateway.main]
}


# ============================================
# NAT GATEWAY
# ============================================
# Placed in public subnet (needs internet access)

resource "aws_nat_gateway" "main" {
  # Allocate Elastic IP (static public IP)
  allocation_id = aws_eip.nat.id

  # Place in public subnet (needs internet access)
  subnet_id = aws_subnet.public_1.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-gateway"
      Task = "T2"
    }
  )

  # Ensure EIP is created first
  depends_on = [aws_eip.nat]
}


# ============================================
# OUTPUTS: NAT GATEWAY
# ============================================

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
