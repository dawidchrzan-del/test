output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs, keyed by AZ"
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}
