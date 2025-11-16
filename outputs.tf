output "vpc_id" {
  value = module.vpc.vpc_id
}

output "database_subnet_cidrs" {
  value = module.vpc.database_subnet_cidrs
}

output "k8s_subnet_cidrs" {
  value = module.vpc.k8s_subnet_cidrs
}

output "public_subnet_cidrs" {
  value = module.vpc.public_subnet_cidrs
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "alb_controller_iam_role_arn" {
  value = module.iam_alb_controller.iam_role_arn
}

output "acm_validation_records_to_create" {
  description = "A map of CNAME records that need to be created in your DNS provider for ACM certificate validation"
  value = {
    for dvo in module.acm.domain_validation_options : dvo.resource_record_name => dvo.resource_record_value
  }
}
