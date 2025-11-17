variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnets, keyed by Availability Zone"
  type        = map(string)
}

variable "private_subnets" {
  description = "A map of private subnets, keyed by Availability Zone"
  type        = map(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
