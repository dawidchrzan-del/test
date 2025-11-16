module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  database_subnet_cidrs = var.database_subnet_cidrs
  k8s_subnet_cidrs      = var.k8s_subnet_cidrs
  public_subnet_cidrs   = var.public_subnet_cidrs
  availability_zones    = var.availability_zones
  cluster_name          = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id             = module.vpc.vpc_id
  k8s_subnet_ids     = module.vpc.k8s_subnet_ids
  cluster_name       = var.cluster_name
  availability_zones = var.availability_zones
  cluster_sg_id      = module.vpc.eks_cluster_sg_id
  node_sg_id         = module.vpc.eks_node_sg_id
}

module "iam_alb_controller" {
  source = "./modules/iam-alb-controller"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id
}

module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = module.acm.certificate_arn
  validation_record_fqdns = [for dvo in module.acm.domain_validation_options : dvo.resource_record_name]
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
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
    value = module.iam_alb_controller.iam_role_arn
  }
}

resource "kubernetes_ingress_v1" "base_ingress" {
  metadata {
    name      = "base-shared-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"      = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/group.name" = "my-apps-group"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTP" = 80}, {"HTTPS" = 443}])
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate_validation.main.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
  }

  spec {
    default_backend {
      service {
        name = "default-http-backend" # This should be a service that returns 404
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
    namespace = "default"
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
    namespace = "default"
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
