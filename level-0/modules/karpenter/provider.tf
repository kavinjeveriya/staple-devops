terraform {
  required_providers {
    kubernetes = {
      source   = "hashicorp/kubernetes"
      version  = "2.37.1"
    }
    kubectl    = {
      source   = "gavinbunney/kubectl"
      version  = ">=1.19.0"
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
