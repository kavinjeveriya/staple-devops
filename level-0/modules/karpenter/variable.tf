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

variable "aws_iam_openid_connect_provider" {
    description = "OpenID for eks service account to assume role"
    type        = string
}

variable "cluster_endpoint" {
    description = "eks cluster endpoint"
    type        = string
}

variable "aws_accountid" {
    description = "The accountid  of the cluster"
    type        = string
}

variable "nodegroup_role_arn" {
    description = "nodegroup role arn"
    type        = string
}

variable "nodegroup_role_name" {
    description = "nodegroup role name"
    type        = string
}
