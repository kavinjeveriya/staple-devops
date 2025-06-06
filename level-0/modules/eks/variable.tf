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

variable "staple_public_subnet_id" {
    description = "This variable get public subnet id from the output of vpc module" 
    type        = list(string)
}

variable "staple_private_subnet_id" {
    description = "This variable get private subnet id from the output of vpc module" 
    type        = list(string)
}


variable "addons" {
    description = "List all the addons we needed for eks cluster" 
    type        = list(string)
    default     = ["vpc-cni", "coredns", "kube-proxy", "aws-ebs-csi-driver"]
}