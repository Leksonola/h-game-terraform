
# ============================================
# PUBLIC SUBNETS
# ============================================
# Subnets with direct internet access
# Use for: Load Balancers, NAT Gateways

# Public Subnet 1
resource "aws_subnet" "public_1" {
  # Belongs to our VPC
  vpc_id = aws_vpc.main.id

  # CIDR block from variable (10.0.1.0/24)
  cidr_block = var.public_subnet_cidrs[0]

  # Availability Zone from variable
  availability_zone = var.availability_zones[0]

  # Enable auto-assign public IP
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-1"
      Type = "public"
      AZ   = var.availability_zones[0]
      Task = "T1"
    }
  )
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-2"
      Type = "public"
      AZ   = var.availability_zones[1]
      Task = "T1"
    }
  )
}

# Public Subnet 3
resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[2]
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-3"
      Type = "public"
      AZ   = var.availability_zones[2]
      Task = "T1"
    }
  )
}

# ============================================
# OUTPUTS: PUBLIC SUBNET IDS
# ============================================

output "public_subnet_1_id" {
  description = "ID of public subnet 1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = aws_subnet.public_2.id
}

output "public_subnet_3_id" {
  description = "ID of public subnet 3"
  value       = aws_subnet.public_3.id
}


# ============================================
# PUBLIC ROUTE TABLE
# ============================================
# Routes traffic from public subnets to Internet Gateway
# This is how public subnets get internet access

resource "aws_route_table" "public" {
  # Belongs to our VPC
  vpc_id = aws_vpc.main.id

  # Route: Send all internet traffic to Internet Gateway
  route {
    cidr_block = var.internet_route_cidr
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
      Type = "public"
      Task = "T1"
    }
  )
}

# ============================================
# PUBLIC SUBNET ROUTE TABLE ASSOCIATIONS
# ============================================
# Connect public subnets to the public route table

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.public.id
}


# ============================================
# PRIVATE SUBNETS
# ============================================
# Subnets WITHOUT direct internet access
# More secure - not directly reachable from the internet
# Use for: Application servers, Databases, Kubernetes nodes

# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id

  # First private CIDR from list
  cidr_block = var.private_subnet_cidrs[0]

  # First Availability Zone
  availability_zone = var.availability_zones[0]

  # No map_public_ip_on_launch (private subnet)
  # Resources won't get public IPs automatically

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-1"
      Type = "private"
      AZ   = var.availability_zones[0]
      Task = "T1"
    }
  )
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id

  # Second private CIDR from list
  cidr_block = var.private_subnet_cidrs[1]

  # Second Availability Zone
  availability_zone = var.availability_zones[1]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-2"
      Type = "private"
      AZ   = var.availability_zones[1]
      Task = "T1"
    }
  )
}

# Private Subnet 3
resource "aws_subnet" "private_3" {
  vpc_id = aws_vpc.main.id

  # Third private CIDR from list
  cidr_block = var.private_subnet_cidrs[2]

  # Third Availability Zone
  availability_zone = var.availability_zones[2]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-3"
      Type = "private"
      AZ   = var.availability_zones[2]
      Task = "T1"
    }
  )
}

# ============================================
# OUTPUTS: PRIVATE SUBNET IDS
# ============================================

output "private_subnet_1_id" {
  description = "ID of private subnet 1"
  value       = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "ID of private subnet 2"
  value       = aws_subnet.private_2.id
}

output "private_subnet_3_id" {
  description = "ID of private subnet 3"
  value       = aws_subnet.private_3.id
}
