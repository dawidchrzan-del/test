output "vpc_id" {
  value = aws_vpc.main.id
}

output "database_subnet_cidrs" {
  value = [for s in aws_subnet.database : s.cidr_block]
}

output "k8s_subnet_cidrs" {
  value = [for s in aws_subnet.k8s : s.cidr_block]
}

output "public_subnet_cidrs" {
  value = [for s in aws_subnet.public : s.cidr_block]
}

output "k8s_subnet_ids" {
  value = [for s in aws_subnet.k8s : s.id]
}

output "eks_cluster_sg_id" {
  description = "The ID of the security group for the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  value       = aws_security_group.eks_nodes.id
}
