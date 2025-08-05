terraform {
  required_version = ">= 1.9.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block                           = var.vpc_cidr
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  ipv6_cidr_block_network_border_group = var.region

  tags = {
    Name = "Production_Explore-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Production_Explore-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, each.key)
  map_public_ip_on_launch = true
  tags = {
    Name = "Production_Explore-subnet-public${each.key + 1}-${element(var.availability_zones, each.key)}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, each.key)
  map_public_ip_on_launch = true
  tags = {
    Name = "Production_Explore-subnet-private${each.key + 1}-${element(var.availability_zones, each.key)}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Production_Explore-rtb-public"
  }
}

resource "aws_route_table" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }


  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Production_Explore-rtb-private${each.key + 1}-${element(var.availability_zones, each.key)}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# TODO add VPC Endpoint