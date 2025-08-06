resource "aws_vpc" "dev" {
  cidr_block                       = var.vpc_cidr_dev
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "${local.dev_name}-vpc"
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr_prod
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "${local.prod_name}-vpc"
  }
}

resource "aws_vpc_peering_connection" "dev_prod" {
  peer_vpc_id = aws_vpc.main.id # target
  vpc_id      = aws_vpc.dev.id  # requester

  tags = {
    "Name" = "Peer_Dev_Production_VPCs"
  }

  depends_on = [aws_vpc.main, aws_vpc.dev]
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_ipv4" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.2.0.0/16"
}

resource "aws_vpc_ipv6_cidr_block_association" "secondary_ipv6" {
  vpc_id                           = aws_vpc.main.id
  assign_generated_ipv6_cidr_block = true
}