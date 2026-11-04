
# ============================================
# EKS NODE GROUP
# ============================================
# EC2 instances that run your Pods.
# Managed by EKS control plane.

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private_1.id, # Private subnet 1
    aws_subnet.private_2.id, # Private subnet 2
    aws_subnet.private_3.id, # Private subnet 3
  ]

  # Instance configuration
  instance_types = [var.eks_node_instance_type]

  # Scaling configuration
  scaling_config {
    desired_size = var.eks_node_desired_size
    min_size     = var.eks_node_min_size
    max_size     = var.eks_node_max_size
  }

  # Update configuration
  update_config {
    max_unavailable = 1 # Update one node at a time
  }

  # Use Spot or On-Demand instances
  capacity_type = var.node_capacity_type

  # Spot Instance Note:
  # Spot instances can be interrupted by AWS with a 2-minute warning.
  #
  # When interrupted:
  # - Kubernetes detects that the node is unavailable.
  # - Pods may be rescheduled to other available nodes.
  # - A replacement node may be provisioned.
  #
  # For learning: Spot can reduce costs.
  # For production: Consider On-Demand for critical workloads
  # or Spot with appropriate PodDisruptionBudgets.

  # AMI (Amazon Machine Image) - EKS optimized
  # EKS automatically selects a compatible AMI for your cluster.

  # Internet Access Note:
  # Nodes are in private subnets (from T1) and need internet access to:
  # - Pull container images from ECR (from T8).
  # - Download Kubernetes components.
  # - Access AWS APIs.
  #
  # This can be handled by the NAT Gateway (from T2), which routes
  # private subnet traffic to the internet.

  # Remote access (SSH) - Optional, for debugging
  # remote_access {
  #   ec2_ssh_key = "your-key-pair-name"
  # }

  # Labels and taints (for advanced scheduling)
  # We'll keep it simple for now.

  # Ensure cluster and IAM roles exist first
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-nodes"
      Task = "T4"
    }
  )
}

# ============================================
# OUTPUT: NODE GROUP NAME
# ============================================

output "eks_node_group_name" {
  description = "Name of the EKS node group"
  value       = aws_eks_node_group.main.node_group_name
}
