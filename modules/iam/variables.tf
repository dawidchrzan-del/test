variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
