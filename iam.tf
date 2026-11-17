
# ============================================
# IAM ROLES FOR EKS
# ============================================
# EKS needs permissions to manage AWS resources.
# This is how EKS creates Load Balancers, attaches
# network interfaces, etc.
# ============================================

# ============================================
# EKS Cluster Role
# ============================================
# Role that EKS cluster assumes.
# Allows the cluster to manage AWS resources.

resource "aws_iam_role" "eks_cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  # Trust policy: Allow EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com" # EKS service can assume this role
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
      Task = "T3"
    }
  )
}

# Attach AWS managed policy: EKS Cluster Policy
# This gives the cluster permissions to manage AWS resources.

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ============================================
# EKS Node Group Role
# ============================================
# Role that worker nodes assume.
# Allows nodes to pull images, write logs, etc.

resource "aws_iam_role" "eks_nodes" {
  name = "${local.name_prefix}-eks-nodes-role"

  # Trust policy: Allow EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com" # EC2 instances (worker nodes) can assume this role
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-nodes-role"
      Task = "T3"
    }
  )
}

# Attach AWS managed policies for worker nodes

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# ============================================
# Outputs: Role ARNs (needed for EKS cluster)
# ============================================

output "eks_cluster_role_arn" {
  description = "ARN of EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  description = "ARN of EKS nodes IAM role"
  value       = aws_iam_role.eks_nodes.arn
}



# ============================================
# EKS OIDC PROVIDER
# ============================================

# Required for IAM Roles for Service Accounts (IRSA)

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-oidc-provider"
      Task = "T7"
    }
  )
}
