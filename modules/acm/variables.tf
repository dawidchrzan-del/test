variable "domain_name" {
  description = "The domain name for which to create the certificate"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
