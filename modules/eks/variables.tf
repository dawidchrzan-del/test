variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Map of private subnet IDs, keyed by AZ"
  type        = map(string)
}

variable "cluster_sg_id" {
  description = "The ID of the security group for the EKS control plane"
  type        = string
}

variable "nodes_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  type        = string
}

variable "node_groups" {
  description = "A map of objects describing the EKS node groups to be created"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND or SPOT
    desired_size   = number
    max_size       = number
    min_size       = number
  }))
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
