variable "region" {
    description = "Choose aws region where we want to create infra"
    type        = string
}

variable "vpc_name" {
    description = "Choose VPC name"
    type        = string
}

variable "vpc_cidr" {
    description = "Choose VPC cidr range for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "tags" {
    description  = "A map of tags, which will add to all resources" 
    type         = map(string)
    default      = {
        Env     = "dev"
        Worktype = "nonprod"
    }
}

variable "public_subnet_cidrs" {
    description = "Choose cidr range for public subnets" 
    type        = list(string)
    default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
    description = "Choose cidr range for private subnets" 
    type        = list(string)
    default     = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
}

variable "azs" {
    description = "Choose availability zones values availabe in a region" 
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}



