variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.198.0.0/16"
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.198.1.0/24", "10.198.2.0/24"]
}

variable "k8s_subnet_cidrs" {
  description = "CIDR blocks for k8s subnets"
  type        = list(string)
  default     = ["10.198.3.0/24", "10.198.4.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.198.5.0/24", "10.198.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
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
