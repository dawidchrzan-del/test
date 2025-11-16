variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
