
# ============================================
# EKS CLUSTER
# ============================================
# AWS managed Kubernetes control plane.
# AWS runs: API server, etcd, controller manager.
# You run: Worker nodes (in T4).

resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  # VPC Configuration
  vpc_config {
    # Subnets where cluster will create resources.
    # Use private subnets (more secure).
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
      aws_subnet.private_3.id,
    ]

    # Endpoint access configuration
    endpoint_private_access = true # Allow access from VPC
    endpoint_public_access  = true # Allow access from internet (for kubectl)

    # Security groups for cluster
    # EKS will create additional security groups automatically.
    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]
  }

  # Enable logging (optional but recommended)
  enabled_cluster_log_types = var.enable_cluster_logging ? var.cluster_log_types : []

  # Ensure IAM roles are created before cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster"
      Task = "T3"
    }
  )
}

# ============================================
# OUTPUTS
# ============================================

# Output: Cluster name
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

# Output: Cluster endpoint (for kubectl)
output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

# Output: Cluster version
output "eks_cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}
