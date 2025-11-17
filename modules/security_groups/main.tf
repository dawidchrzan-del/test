# Public ALB Security Group
resource "aws_security_group" "alb_public" {
  name        = "${var.name}-alb-public-sg"
  description = "Security group for the public ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-alb-public-sg"
  })
}

# EKS Control Plane Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.name}-eks-cluster-sg"
  description = "Security group for the EKS control plane"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-eks-cluster-sg"
  })
}

# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.name}-eks-nodes-sg"
  description = "Security group for the EKS nodes"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-eks-nodes-sg"
  })
}

# --- Communication Rules ---

# Nodes -> Control Plane (for kubectl exec, logs, etc.)
resource "aws_security_group_rule" "node_to_cluster_https" {
  type                     = "ingress"
  description              = "Allow nodes to communicate with control plane"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "cluster_to_node_https" {
  type                     = "egress"
  description              = "Allow control plane to communicate with nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}


# Control Plane -> Nodes (for kubelet)
resource "aws_security_group_rule" "cluster_to_node_kubelet" {
  type                     = "ingress"
  description              = "Allow control plane to communicate with kubelet"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# ALB -> Nodes
resource "aws_security_group_rule" "alb_to_node" {
  type                     = "ingress"
  description              = "Allow ALB to communicate with nodes on ephemeral ports"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_public.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# Nodes -> Nodes (for CNI and general pod communication)
resource "aws_security_group_rule" "node_to_node_all" {
  type                     = "ingress"
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
}
