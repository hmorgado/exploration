locals {
  public_ipv6_cidrs = [
    "2600:1f1c:3c5:ec00::/64",
    "2600:1f1c:3c5:ec01::/64",
  ]

  private_ipv6_cidrs = [
    "2600:1f1c:3c5:ec02::/64",
    "2600:1f1c:3c5:ec03::/64",
    "2600:1f1c:3c5:ec04::/64",
    "2600:1f1c:3c5:ec05::/64"
  ]
}