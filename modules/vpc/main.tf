resource "aws_vpc" "nick_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "nick_vpc"
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "nick_ig" {
  vpc_id = aws_vpc.nick_vpc.id
  tags = {
    Name = "nick_igw"
  }
}

# Elastic_IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.nick_ig]
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.nick_subnet_public.*.id, 0)
  depends_on    = [aws_subnet.nick_subnet_public]

  tags = {
    Name = "nat"
  }
}

# public subset
resource "aws_subnet" "nick_subnet_public" {
  vpc_id                  = aws_vpc.nick_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true //it makes this a public subnet
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "nick_subnet_public"
  }
}

resource "aws_subnet" "nick_subnet_public_1" {
  vpc_id                  = aws_vpc.nick_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_region.current.name}b"

  tags = {
    Name = "nick_subnet_public_1"
  }
}

# Private Subnet
resource "aws_subnet" "nick_subnet_private" {
  vpc_id                  = aws_vpc.nick_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_region.current.name}a"

  tags = {
    Name = "nick_subnet_private"
  }
}

# Private route table
resource "aws_route_table" "nick_private_route_table" {
  vpc_id = aws_vpc.nick_vpc.id

  tags = {
    Name = "nick_private_route_table"
  }
}

# public route table
resource "aws_route_table" "nick_public_route_table" {
  vpc_id = aws_vpc.nick_vpc.id

  tags = {
    Name = "nick_public_route_table"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.nick_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nick_ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.nick_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  subnet_id      = element(aws_subnet.nick_subnet_public.*.id, 1)
  route_table_id = aws_route_table.nick_public_route_table.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = element(aws_subnet.nick_subnet_public_1.*.id, 1)
  route_table_id = aws_route_table.nick_public_route_table.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = element(aws_subnet.nick_subnet_private.*.id, 1)
  route_table_id = aws_route_table.nick_private_route_table.id
}

# Default Security Group of VPC
resource "aws_security_group" "nick_default" {
  name        = "nick-default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.nick_vpc.id
  depends_on = [
    aws_vpc.nick_vpc
  ]

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }
}
