output "alb_public_sg_id" {
  description = "The ID of the security group for the public ALB"
  value       = aws_security_group.alb_public.id
}

output "eks_cluster_sg_id" {
  description = "The ID of the security group for the EKS control plane"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  value       = aws_security_group.eks_nodes.id
}
