output "staple_vpc_id" {
    value = aws_vpc.staple_vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.staple_vpc.cidr_block
}

output "staple_public_subnet_id" {
    value = aws_subnet.stple_public_subnets[*].id
}

output "staple_private_subnet_id" {
    value = aws_subnet.stple_private_subnets[*].id
}
