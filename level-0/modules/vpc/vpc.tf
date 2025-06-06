resource "aws_vpc" "staple_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-vpc"
      Terraform = "true"  
    }
  )
}

resource "aws_subnet" "stple_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.staple_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-vpc-public-subnet ${count.index + 1}"
      Terraform = "true"  
      Type      = "${var.vpc_name}-vpc-public"
    }
  )
}

resource "aws_subnet" "stple_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.staple_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-vpc-private-subnet ${count.index + 1}"
      Terraform = "true"  
      Type      = "${var.vpc_name}-vpc-private"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.staple_vpc.id
  tags   = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-igw"
      Terraform = "true"  
    }
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.staple_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }

  tags         = merge (
    var.tags,
    {
      Name      = "public-route-table"
      Terraform = "true"  
    }
  )
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.stple_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-nat-eip"
      Terraform = "true"  
    }
  )
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.stple_public_subnets[0].id
  tags          = merge (
    var.tags,
    {
      Name      = "${var.vpc_name}-ngw"
      Terraform = "true"  
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.staple_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id 
  }

  tags             = merge (
    var.tags,
    {
      Name      = "private-route-table"
      Terraform = "true"  
    }
  )
}

resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.stple_private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}