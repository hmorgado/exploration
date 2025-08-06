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

