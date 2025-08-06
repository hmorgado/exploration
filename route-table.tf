resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env_name}-rtb-public"
  }
}

locals {
  nat_gws = {
    "us-west-1a" = aws_nat_gateway.nat_gw_a.id
    "us-west-1c" = aws_nat_gateway.nat_gw_c.id
  }
}

resource "aws_route_table" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = local.nat_gws[element(var.availability_zones, each.key)]
  }

  tags = {
    Name = "${local.env_name}-rtb-private${each.key + 1}-${element(var.availability_zones, each.key)}"
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

resource "aws_route_table" "isolated_dev_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Isolated_Dev_Nat_Gateway_${var.availability_zones[0]}"
  }
}