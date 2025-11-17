variable "aws_region" {
  description = "AWS region for the environment"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the environment"
  type        = string
  default     = "prd"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "prd"
    Project     = "my-eks-project"
    ManagedBy   = "Terraform"
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "A map of public subnets, keyed by Availability Zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.20.1.0/24"
    "us-east-1b" = "10.20.2.0/24"
    "us-east-1c" = "10.20.3.0/24"
  }
}

variable "private_subnets" {
  description = "A map of private subnets, keyed by Availability Zone"
  type        = map(string)
  default = {
    "us-east-1a" = "10.20.11.0/24"
    "us-east-1b" = "10.20.12.0/24"
    "us-east-1c" = "10.20.13.0/24"
  }
}

variable "node_groups" {
  description = "Configuration for EKS node groups"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    max_size       = number
    min_size       = number
  }))
  default = {
    "ondemand-c6xl" = {
      instance_types = ["c6a.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      max_size       = 5
      min_size       = 3
    }
  }
}

variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}
