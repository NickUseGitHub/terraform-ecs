output "vpc_instance" {
  value = aws_vpc.nick_vpc
}

output "vpc_public_subnet" {
  value = aws_subnet.nick_subnet_public
}

output "vpc_public_subnet_1" {
  value = aws_subnet.nick_subnet_public_1
}
