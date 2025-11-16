variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "k8s_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for the node groups"
  type        = list(string)
}

variable "cluster_sg_id" {
  description = "The ID of the security group for the EKS cluster"
  type        = string
}

variable "node_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  type        = string
}
