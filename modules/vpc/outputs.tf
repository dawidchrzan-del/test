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
