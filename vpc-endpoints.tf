# Use this to communicate with S3 buckets through AWS private connections without going through internet
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway" # default
  service_name      = "com.amazonaws.us-west-1.s3"

  # this will add an entry in the RTBs for destination "pl" (prefix list) targeting this VPC Endpoint
  route_table_ids = local.private_route_table_ids

  tags = { "Name" : "S3 Gateway VPC Endpoint" }
}

resource "aws_vpc_endpoint" "interface" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface" # default
  service_name      = "com.amazonaws.us-west-1.rds"

  #                    returns 2 subnets, one in each AZ
  subnet_ids         = [for az in var.availability_zones : local.private_subnet_ids_map_per_region[az][0]]
  security_group_ids = [aws_security_group.sg["database"].id]

  tags = { "Name" : "RDS Interface VPC Endpoint" }

  depends_on = [aws_security_group.sg]
}