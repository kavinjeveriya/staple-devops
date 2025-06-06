# EKS NodeGroup IAM Role
resource "aws_iam_role" "nodegroup_role" {
  name = "${var.eks_cluster_name}-worker-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_iam_role_policy" "inline_policy" {
  name   = "ec2_volume"
  role   = aws_iam_role.nodegroup_role.name  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:CreateVolume"
        ],
        Resource = [
          "arn:aws:ec2:us-east-1:895533345638:volume/*",
          "arn:aws:ec2:us-east-1:895533345638:instance/*"
        ]
      },
      {
        Sid      = "VisualEditor1",
        Effect   = "Allow",
        Action   = "ec2:DescribeTags",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "inline_policy_ecr" {
  name   = "ecr"
  role   = aws_iam_role.nodegroup_role.name  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "VisualEditor0",
        Effect = "Allow",
        "Action": [
                "ecr:DescribePullThroughCacheRules",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeImages",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:ListImages",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
        ],
        Resource = [
          "arn:aws:ecr:us-east-1:895533345638:repository/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "nodegroup_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup_role.name
}


# EKS Node Groups
resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.eks_cluster_name}-karpenter-node"
  node_role_arn   = aws_iam_role.nodegroup_role.arn
  subnet_ids      = var.staple_private_subnet_id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  ami_type       = "AL2_x86_64" 
  capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
  disk_size      = 20
  instance_types = ["t3.medium"]

  tags = merge(
    var.tags,
    {
      Terraform = "true"  
      Name      = "${var.eks_cluster_name}-karpenter-node"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.nodegroup_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodegroup_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodegroup_AmazonEC2ContainerRegistryReadOnly,
  ]
}