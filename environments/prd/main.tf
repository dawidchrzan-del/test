terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name" # ZASTĄP NAZWĄ SWOJEGO BUCKETA
    key            = "prd/terraform.tfstate"            # Dedykowany plik stanu dla 'prd'
    region         = "us-east-1"                        # ZMIEŃ NA SWÓJ REGION
    dynamodb_table = "your-terraform-state-lock-table"  # ZASTĄP NAZWĄ SWOJEJ TABELI
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Module Composition ---

module "vpc" {
  source = "../../modules/vpc"

  name            = var.name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  name   = var.name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr_block
  tags   = var.tags
}

module "eks" {
  source = "../../modules/eks"

  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_sg_id      = module.security_groups.eks_cluster_sg_id
  nodes_sg_id        = module.security_groups.eks_nodes_sg_id
  node_groups        = var.node_groups
  tags               = var.tags

  depends_on = [module.vpc]
}

# --- ALB, ACM and Helm Logic ---

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

module "iam_alb_controller" {
  source = "../../modules/iam"

  name              = var.name
  oidc_provider_arn = module.eks.oidc_provider_arn
  aws_region        = var.aws_region
  tags              = var.tags
}

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for dvo in aws_acm_certificate.main.domain_validation_options : dvo.resource_record_name]
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.3"

  set {
    name  = "clusterName"
    value = var.name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_alb_controller.alb_controller_role_arn
  }
}

resource "kubernetes_ingress_v1" "base_ingress" {
  metadata {
    name      = "base-shared-ingress"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/ingress.class"      = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/group.name" = "${var.name}-group"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTP" = 80}, {"HTTPS" = 443}])
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate_validation.main.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
  }
  spec {
    default_backend {
      service {
        name = "default-http-backend"
        port {
          number = 80
        }
      }
    }
  }
  depends_on = [helm_release.alb_controller]
}

resource "kubernetes_deployment_v1" "default_backend" {
  metadata {
    name      = "default-http-backend"
    namespace = "kube-system"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "default-http-backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "default-http-backend"
        }
      }
      spec {
        container {
          image = "gcr.io/google_containers/defaultbackend:1.0"
          name  = "default-http-backend"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default_backend" {
  metadata {
    name      = "default-http-backend"
    namespace = "kube-system"
  }
  spec {
    selector = {
      app = "default-http-backend"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}
