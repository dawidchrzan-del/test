variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "database_subnet_cidrs" {
  description = "A map of CIDR blocks for database subnets, keyed by Availability Zone"
  type        = map(string)
}

variable "k8s_subnet_cidrs" {
  description = "A map of CIDR blocks for k8s subnets, keyed by Availability Zone"
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "A map of CIDR blocks for public subnets, keyed by Availability Zone"
  type        = map(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
