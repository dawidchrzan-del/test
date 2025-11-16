output "eks_cluster_sg_id" {
  description = "The ID of the security group for the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  value       = aws_security_group.eks_nodes.id
}
