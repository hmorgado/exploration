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

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = each.value
  availability_zone               = element(var.availability_zones, each.key)
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  ipv6_cidr_block = local.public_ipv6_cidrs[each.key]


  tags = {
    Name = "${local.prod_name}-subnet-public${each.key + 1}-${element(var.availability_zones, each.key)}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id                          = aws_vpc.main.id
  cidr_block                      = each.value
  availability_zone               = element(var.availability_zones, each.key)
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = local.private_ipv6_cidrs[each.key]
  tags = {
    Name = "${local.prod_name}-subnet-private${each.key + 1}-${element(var.availability_zones, each.key)}"
  }
}


# IPv4 and IPv6 subnets - chap 3 "Create Subnets"
resource "aws_subnet" "isolated_dev_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.64.0/26"
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "Isolated_Dev_US_West_1a"
  }
}

# us-west-1b wasn't available
resource "aws_subnet" "isolated_dev_c" {
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.0.65.0/26" # due to error: MissingParameter: Either 'cidrBlock' or 'ipv4IpamPoolId' should be provided. https://github.com/hashicorp/terraform-provider-aws/issues/42414
  availability_zone               = var.availability_zones[1]
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = "2600:1f1c:fbb:1e06::/64"
  tags = {
    Name = "Isolated_Dev_US_West_1c"
  }
}