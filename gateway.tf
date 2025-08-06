# associations done in route-table.tf
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.env_name}-igw"
  }
}

# EIGW (Egress Only Internet GW for EC2 instances with IPv6
# that reside in a private subnet and need internet access
# without exposing them. It's similar to a NATGW but for IPv6
resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.env_name}-eigw"
  }
}

resource "aws_eip" "eip_a" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "eip_c" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw_a" {
  subnet_id = data.aws_subnet.public_a.id

  connectivity_type = "public"
  allocation_id = aws_eip.eip_a.allocation_id

  tags = {
    "Name" = "${local.env_name}_Nat_GW"
  }

  depends_on = [aws_eip.eip_a]
}

resource "aws_nat_gateway" "nat_gw_c" {
  subnet_id = data.aws_subnet.public_c.id

  connectivity_type = "public"
  allocation_id = aws_eip.eip_c.allocation_id

  tags = {
    "Name" = "${local.env_name}_Nat_GW"
  }

  depends_on = [aws_eip.eip_c]
}



