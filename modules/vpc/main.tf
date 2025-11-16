locals {
  public_subnets   = zipmap(var.availability_zones, var.public_subnet_cidrs)
  k8s_subnets      = zipmap(var.availability_zones, var.k8s_subnet_cidrs)
  database_subnets = zipmap(var.availability_zones, var.database_subnet_cidrs)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

resource "aws_subnet" "database" {
  for_each          = local.database_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(var.tags, {
    Name = "database-subnet-${each.key}"
  })
}

resource "aws_subnet" "k8s" {
  for_each          = local.k8s_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(var.tags, {
    Name                                  = "k8s-subnet-${each.key}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "public-subnet-${each.key}"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each   = toset(var.availability_zones)
  depends_on = [aws_internet_gateway.main]
  tags = merge(var.tags, {
    Name = "nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "main" {
  for_each      = toset(var.availability_zones)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = merge(var.tags, {
    Name = "nat-gateway-${each.key}"
  })
}

resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = merge(var.tags, {
    Name = "private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "k8s" {
  for_each       = aws_subnet.k8s
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "database" {
  for_each       = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
