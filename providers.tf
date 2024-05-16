terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "aws" {
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config-${var.project_name}"
    config_context = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config-${var.project_name}"
  config_context = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}"
}

provider "kubectl" {
  config_path    = "~/.kube/config-${var.project_name}"
  config_context = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}"
}