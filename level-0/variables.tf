variable "region" {
    description = "Choose aws region where we want to create infra"
    type        = string
    default     = "us-east-1"
}

variable "vpc_name" {
    description = "Choose VPC name"
    type        = string
    default     = "staple-nvirginia"
}

variable "eks_cluster_name" {
    description = "Choose eks cluster name"
    type        = string
    default     = "dev-staple"
}

variable "aws_accountid" {
    description = "Provide AWS account id number"
    type        = string
    default     = "895533345638"
}
