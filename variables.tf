variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.198.0.0/16"
}

variable "database_subnet_cidrs" {
  description = "A map of CIDR blocks for database subnets, keyed by Availability Zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.198.1.0/24"
    "us-east-1b" = "10.198.2.0/24"
  }
}

variable "k8s_subnet_cidrs" {
  description = "A map of CIDR blocks for k8s subnets, keyed by Availability Zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.198.3.0/24"
    "us-east-1b" = "10.198.4.0/24"
  }
}

variable "public_subnet_cidrs" {
  description = "A map of CIDR blocks for public subnets, keyed by Availability Zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.198.5.0/24"
    "us-east-1b" = "10.198.6.0/24"
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
  default     = "example.com"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks-terraform"
    ManagedBy   = "Terraform"
  }
}
