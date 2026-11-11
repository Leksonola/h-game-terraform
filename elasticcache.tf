
# ============================================
# ELASTICACHE REDIS (Managed Cache)
# ============================================

# AWS managed Redis
# Replaces: Redis Deployment (from K3)

# ============================================
# CACHE SUBNET GROUP
# ============================================

# Tells ElastiCache which subnets to use.
# ElastiCache needs subnets in multiple AZs.

resource "aws_elasticache_subnet_group" "main" {
  name = "${local.name_prefix}-cache-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id, # Private subnet 1 (us-east-1a)
    aws_subnet.private_2.id, # Private subnet 2 (us-east-1b)
    aws_subnet.private_3.id, # Private subnet 3 (us-east-1c)
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cache-subnet-group"
      Task = "T6"
    }
  )
}

# ============================================
# OUTPUT: SUBNET GROUP NAME
# ============================================

output "cache_subnet_group_name" {
  description = "Name of the cache subnet group"
  value       = aws_elasticache_subnet_group.main.name
}


# ============================================
# ELASTICACHE REDIS CLUSTER
# ============================================

# Managed Redis cache
# AWS handles: Backups, updates, monitoring

resource "aws_elasticache_replication_group" "redis" {

  # Basic configuration
  replication_group_id = var.redis_cluster_id
  description          = "${var.project_name} Redis cache"
  engine               = "redis"
  engine_version       = "7.0"

  # Node configuration
  node_type = var.elasticache_node_type
  port      = var.redis_port

  # Cluster configuration
  num_cache_clusters = 1 # Single node for learning (saves cost)

  # For production: Use num_cache_clusters = 2+ for Multi-AZ

  # Network configuration
  subnet_group_name   = aws_elasticache_subnet_group.main.name
  security_group_ids  = [aws_security_group.cache.id]

  # Parameter group (optional - defaults work fine)
  # parameter_group_name = "default.redis7"

  # Snapshot configuration (optional - for persistence)
  snapshot_retention_limit = 0 # 0 = no snapshots (ephemeral, saves cost)

  # For production: Set to 1-5 days for cache backups

  # Automatic failover (requires Multi-AZ)
  automatic_failover_enabled = false

  # Requires num_cache_clusters >= 2
  # For production: Set to true with Multi-AZ

  # Maintenance window
  maintenance_window = "mon:05:00-mon:06:00" # UTC

  # Tags
  tags = merge(
    local.common_tags,
    {
      Name = var.redis_cluster_id
      Task = "T6"
    }
  )

  # Ensure subnet group and security group exist first
  depends_on = [
    aws_elasticache_subnet_group.main,
    aws_security_group.cache,
  ]
}

# ============================================
# OUTPUT: ELASTICACHE ENDPOINT
# ============================================

output "elasticache_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# ============================================
# OUTPUT: ELASTICACHE PORT
# ============================================

output "elasticache_port" {
  description = "ElastiCache Redis port"
  value       = aws_elasticache_replication_group.redis.port
}
