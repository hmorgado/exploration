locals {

  dev_name  = "Dev_Explore"
  prod_name = "Production_Explore"

  public_ipv6_cidrs = [
    "2600:1f1c:fbb:1e00::/64",
    "2600:1f1c:fbb:1e01::/64",
  ]

  private_ipv6_cidrs = [
    "2600:1f1c:fbb:1e02::/64",
    "2600:1f1c:fbb:1e03::/64",
    "2600:1f1c:fbb:1e04::/64",
    "2600:1f1c:fbb:1e05::/64",
  ]

  # rules, ports, etc could be moved here
  security_groups = {
    load_balancer = {}
    web_tier      = {}
    database      = {}
  }

  isolated_subnet_ids = [
    data.aws_subnet.isolated_a.id,
    data.aws_subnet.isolated_c.id
  ]

  # returns a list of ids for private subnets
  private_subnet_ids = [for idx in range(length(aws_subnet.private)) : aws_subnet.private[idx].id]

  # returns a list of ids for private route tables
  private_route_table_ids = [for idx in range(length(aws_route_table.private)) : aws_route_table.private[idx].id]

  # the ellipsis (...) at the end of the expression allows for grouping (map) when the key (AZs) repeats, returning:
  # {
  #   "us-west-1a" = ["subnet-1", "subnet-2"]
  #   "us-west-1c" = ["subnet-3", "subnet-4"]
  # }
  private_subnet_ids_map_per_region = {
    for idx in range(length(aws_subnet.private)) : aws_subnet.private[idx].availability_zone => aws_subnet.private[idx].id ...
  }

  # needs "." at the end of FQDN to avoid perpetual changes
  blocked_websites = ["virus-765431fd89e.com.", "sdhfiuwwh98723475.info.", "defnotagoodwebsitetoclick.io."]
}