data "aws_ecrpublic_authorization_token" "token" {}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart      = "karpenter"
  version    = "1.5.0"
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }
  set {
    name  = "settings.clusterName"
    value = "${var.eks_cluster_name}-cluster"
  }
  
  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_interruption_queue.name
  }
  set {
    name  = "settings.defaultInstanceProfile"
    value = "KarpenterNodeInstanceProfile"
  }
}


