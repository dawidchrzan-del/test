output "vpc_id" {
  value = aws_vpc.main.id
}

output "database_subnet_cidrs" {
  description = "Map of database subnet CIDRs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.database : az => subnet.cidr_block }
}

output "k8s_subnet_cidrs" {
  description = "Map of Kubernetes subnet CIDRs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.k8s : az => subnet.cidr_block }
}

output "public_subnet_cidrs" {
  description = "Map of public subnet CIDRs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.public : az => subnet.cidr_block }
}

output "k8s_subnet_ids" {
  description = "Map of Kubernetes subnet IDs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.k8s : az => subnet.id }
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}
