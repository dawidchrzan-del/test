variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "k8s_subnet_ids" {
  description = "Map of subnet IDs for the EKS cluster, keyed by AZ"
  type        = map(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_sg_id" {
  description = "The ID of the security group for the EKS cluster"
  type        = string
}

variable "node_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  type        = string
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}
