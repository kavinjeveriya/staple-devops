module "vpc" {
    source   = "./modules/vpc"
    region   = var.region
    vpc_name = var.vpc_name
}

module "eks-cluster" {
    source   = "./modules/eks"
    staple_public_subnet_id = module.vpc.staple_public_subnet_id
    staple_private_subnet_id = module.vpc.staple_private_subnet_id
    region = var.region
    eks_cluster_name = var.eks_cluster_name
}

module "karpenter" {
    source                          = "./modules/karpenter"
    region                          = var.region
    eks_cluster_name                = var.eks_cluster_name
    aws_iam_openid_connect_provider = module.eks-cluster.aws_iam_openid_connect_provider
    cluster_endpoint                = module.eks-cluster.cluster_endpoint
    aws_accountid                   = var.aws_accountid
    nodegroup_role_arn              = module.eks-cluster.nodegroup_role_arn
    nodegroup_role_name             = module.eks-cluster.nodegroup_role_name
}

module "aws-ingress-controller" {
  source                          = "./modules/aws-ingress-controller"
  eks_cluster_name                = var.eks_cluster_name
  region                          = var.region
  aws_iam_openid_connect_provider = module.eks-cluster.aws_iam_openid_connect_provider
  cluster_endpoint                = module.eks-cluster.cluster_endpoint
  aws_accountid                   = var.aws_accountid
}

