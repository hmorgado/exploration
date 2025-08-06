################################################################
# 3 SGs defined here (load balancer, web tier, database)
# traffic flow: load balancer -> web tier -> database (and back)
################################################################

resource "aws_security_group" "sg" {
  for_each = { for key, value in local.security_groups : key => value }

  vpc_id = aws_vpc.main.id
  name   = title(replace(each.key, "_", " ")) # for ex, turns load_balancer into Load Balancer

  tags = {
    "Name" = title(replace(each.key, "_", " "))
  }
}

# INBOUND
resource "aws_vpc_security_group_ingress_rule" "from_internet" {
  security_group_id = aws_security_group.sg["load_balancer"].id

  ip_protocol = "TCP"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    "Name" = "Allow traffic from internet"
  }
}

# OUTBOUND
resource "aws_vpc_security_group_egress_rule" "to_web_tier" {
  security_group_id = aws_security_group.sg["load_balancer"].id

  ip_protocol                  = "TCP"
  from_port                    = 0
  to_port                      = 0
  referenced_security_group_id = aws_security_group.sg["web_tier"].id

  tags = {
    "Name" = "Allow traffic to Web Tier SG"
  }
}

# INBOUND
resource "aws_vpc_security_group_ingress_rule" "from_load_balancer" {
  security_group_id = aws_security_group.sg["web_tier"].id

  ip_protocol                  = "TCP"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.sg["load_balancer"].id
  tags = {
    "Name" = "Allow traffic from load balancer"
  }
}

# OUTBOUND
resource "aws_vpc_security_group_egress_rule" "to_database" {
  security_group_id = aws_security_group.sg["web_tier"].id

  ip_protocol                  = "TCP"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.sg["database"].id

  tags = {
    "Name" = "Allow traffic to Database"
  }
}

# INBOUND
resource "aws_vpc_security_group_ingress_rule" "from_web_tier" {
  security_group_id = aws_security_group.sg["database"].id

  ip_protocol                  = "TCP"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.sg["web_tier"].id

  tags = {
    "Name" = "Allow traffic from Web Tier"
  }
}
