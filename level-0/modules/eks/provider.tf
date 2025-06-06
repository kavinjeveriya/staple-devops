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

