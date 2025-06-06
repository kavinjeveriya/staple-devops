resource "helm_release" "aws_ingress_controller" {
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  version    = var.helm_chart_version
  repository = var.helm_chart_repo
  namespace  = var.namespace

  set {
    name  = "clusterName"
    value = "${var.eks_cluster_name}-cluster"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }
  
  set {
  name = "enableServiceMutatorWebhook"
  value = "false"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_ingress_controller.arn
  }

  values = [
    yamlencode(var.settings)
  ]
}
