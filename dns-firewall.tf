resource "aws_route53_resolver_firewall_domain_list" "mal" {
  name = "Malicious websites"

  domains = local.blocked_websites
}

resource "aws_route53_resolver_firewall_rule_group" "mal" {
  name = "Malicious websites"
}

resource "aws_route53_resolver_firewall_rule" "block" {
  name = "Blocked websites"

  action                  = "BLOCK"
  block_override_ttl      = 1
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.mal
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.mal
}