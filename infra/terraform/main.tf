terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "notesy" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "notesy-vpc"
    Project = "notesy-app"
  }
}

resource "aws_internet_gateway" "notesy" {
  vpc_id = aws_vpc.notesy.id

  tags = {
    Name    = "notesy-igw"
    Project = "notesy-app"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.notesy.id
  cidr_block              = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "notesy-public-${count.index + 1}"
    Project = "notesy-app"
    Tier    = "public"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.notesy.id
  cidr_block        = count.index == 0 ? "10.0.11.0/24" : "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "notesy-private-${count.index + 1}"
    Project = "notesy-app"
    Tier    = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.notesy.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.notesy.id
  }

  tags = {
    Name    = "notesy-public-rt"
    Project = "notesy-app"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "notesy-nat-eip"
    Project = "notesy-app"
  }
}

resource "aws_nat_gateway" "notesy" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.notesy]

  tags = {
    Name    = "notesy-nat"
    Project = "notesy-app"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.notesy.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.notesy.id
  }

  tags = {
    Name    = "notesy-private-rt"
    Project = "notesy-app"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
