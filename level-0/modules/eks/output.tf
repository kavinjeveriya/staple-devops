output "eks_cluster_name" {
	value = aws_eks_cluster.eks.name
}

output "nodegroup_role_name" {
	value = aws_iam_role.nodegroup_role.name
}

output "nodegroup_role_arn" {
	value = aws_iam_role.nodegroup_role.arn
}

output "nodegroup_name" {
	value = aws_eks_node_group.eks_nodegroup.node_group_name
}

output "aws_iam_openid_connect_provider" {
	value = aws_iam_openid_connect_provider.eks.url
}

output "cluster_endpoint" {
	value = aws_iam_openid_connect_provider.eks.arn
}

output "eks_endpoint" {
	value = aws_eks_cluster.eks.endpoint
}
