resource "aws_vpc" "nick-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "nick-vpc"
  }
}

resource "aws_subnet" "nick-subnet-public-1" {
    vpc_id = "${aws_vpc.nick-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "${data.aws_region.current.name}a"
    tags = {
        Name = "nick-subnet-public-1"
    }
}
