#data "aws_iam_instance_profile" "check_existing_karpenter_node_instaceprofile" {
#  name = "KarpenterNodeInstanceProfile"
#}

data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_iam_openid_connect_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
    principals {
      identifiers = [var.cluster_endpoint]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
  name               = "KarpenterController-${var.eks_cluster_name}-cluster"
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_iam_role_policy" "karpenter_controller_inline_policy" {
  name = "karpenter-controller-inline-policy"
  role = aws_iam_role.karpenter_controller.name

  policy = templatefile("./modules/karpenter/karpenterControllerPolicy.json", {
    eks_cluster_name              = var.eks_cluster_name
    aws_accountid                = var.aws_accountid
    region                        = var.region
    KarpenterNodeRoleArn          = var.nodegroup_role_arn
    KarpenterInterruptionQueueArn = aws_sqs_queue.karpenter_interruption_queue.arn
  })
}

resource "aws_iam_instance_profile" "karpenter" {
  #count = length(data.aws_iam_instance_profile.check_existing_karpenter_node_instaceprofile) > 0 ? 0 : 1
  name = "KarpenterNodeInstanceProfile"
  role = var.nodegroup_role_name
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

