data "aws_iam_policy_document" "ingress_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_iam_openid_connect_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      identifiers = [var.cluster_endpoint]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_ingress_controller" {
  assume_role_policy = data.aws_iam_policy_document.ingress_controller_assume_role_policy.json
  name               = "AwsIngressController-${var.eks_cluster_name}-cluster-${var.region}"
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_iam_policy" "ingress_controller_1" {
  policy = file("./modules/aws-ingress-controller/ingress-controller-default-policy.json")
  name   = "AwsIngressControllerDefault-policy"
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}
resource "aws_iam_policy" "ingress_controller_2" {
  policy = file("./modules/aws-ingress-controller/ingress-controller-addon-policy.json")
  name   = "AwsIngressControllerAddon-policy"
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}
resource "aws_iam_role_policy_attachment" "ingress_controller_attach-1" {
  role       = aws_iam_role.aws_ingress_controller.name
  policy_arn = aws_iam_policy.ingress_controller_1.arn
}
resource "aws_iam_role_policy_attachment" "ingress_controller_attach-2" {
  role       = aws_iam_role.aws_ingress_controller.name
  policy_arn = aws_iam_policy.ingress_controller_2.arn
}
