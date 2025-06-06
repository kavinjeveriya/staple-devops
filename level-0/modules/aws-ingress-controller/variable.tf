variable "region" {
    description = "Choose aws region where we want to create infra"
    type        = string
}

variable "eks_cluster_name" {
    description = "Choose eks cluster name"
    type        = string
}

variable "tags" {
    description  = "A map of tags, which will add to all resources" 
    type         = map(string)
    default      = {
        Env      = "dev"
        Worktype = "nonprod"
    }
}

variable "helm_chart_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "ALB Controller Helm chart name to be installed"
}

variable "helm_chart_release_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "Helm release name"
}

variable "helm_chart_version" {
  type        = string
  default     = "1.13.2"
  description = "ALB Controller Helm chart version."
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://aws.github.io/eks-charts"
  description = "ALB Controller repository url."
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy ALB Controller Helm chart."
}

variable "aws_accountid" {
  type        = string
  description = "The accountid  of the cluster"
}

variable "service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "ALB Controller service account name"
}

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}

variable "aws_iam_openid_connect_provider" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}
