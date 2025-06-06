# EKS Cluster IAM Role
resource "aws_iam_role" "cluster_role" {
  name = "${var.eks_cluster_name}-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

tags   = merge (
    var.tags,
    {
      Terraform = "true"  
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "${var.eks_cluster_name}-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.32"

  vpc_config {
    subnet_ids              = flatten([var.staple_public_subnet_id, var.staple_private_subnet_id])
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Terraform = "true"  
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_addon" "addons" {
  for_each                    = toset(var.addons)
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = each.key
  #addon_version              = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}


resource "aws_ec2_tag" "add_tag_to_eks_cluster_sg" {
  resource_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = "${var.eks_cluster_name}-cluster"

  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.eks_cluster_name}-cluster"
  }

  triggers = {
    cluster_name = "${var.eks_cluster_name}-cluster"
  }

  depends_on = [
    resource.aws_eks_cluster.eks
  ]
}

