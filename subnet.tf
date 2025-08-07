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