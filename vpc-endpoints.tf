# Use this to communicate with S3 buckets through AWS private connections without going through internet
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway" # default
  service_name      = "com.amazonaws.us-west-1.s3"

  # this will add an entry in the RTBs for destination "pl" (prefix list) targeting this VPC Endpoint
  route_table_ids = local.private_route_table_ids

  tags = { "Name" : "S3 Gateway VPC Endpoint" }
}