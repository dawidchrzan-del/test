variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster, used for tagging resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
