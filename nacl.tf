resource "aws_network_acl" "https" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "443 Traffic"
  }
}

# IPv4
resource "aws_network_acl_rule" "https_in" {
  network_acl_id = aws_network_acl.https.id

  rule_number = 100
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
}

# IPv4
resource "aws_network_acl_rule" "https_out" {
  network_acl_id = aws_network_acl.https.id

  egress      = true
  rule_number = 100
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  rule_action = "allow"
  cidr_block  = "0.0.0.0/0"
}

# IPv6
resource "aws_network_acl_rule" "https_in_ipv6" {
  network_acl_id = aws_network_acl.https.id

  rule_number     = 200
  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
}

# IPv6
resource "aws_network_acl_rule" "https_out_ipv6" {
  network_acl_id = aws_network_acl.https.id

  egress          = true
  rule_number     = 200
  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  rule_action     = "allow"
  ipv6_cidr_block = "::/0"
}

data "aws_subnet" "isolated_a" {
  filter {
    name   = "tag:Name"
    values = ["Isolated_Dev_US_West_1a"]
  }
}

data "aws_subnet" "isolated_c" {
  filter {
    name   = "tag:Name"
    values = ["Isolated_Dev_US_West_1c"]
  }
}

# associates NACL with Isolated subnets
resource "aws_network_acl_association" "https" {
  for_each = { for idx, subnet_id in local.isolated_subnet_ids : idx => subnet_id }

  network_acl_id = aws_network_acl.https.id
  subnet_id      = each.value
}