terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}

#Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
}
