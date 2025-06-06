terraform {
  required_providers {
    helm = {
        source  = "hashicorp/helm"
        version = "~> 2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "arn:aws:eks:${var.region}:${var.aws_accountid}:cluster/${var.eks_cluster_name}-cluster"   
  }
}
