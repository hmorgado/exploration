resource "aws_security_group" "sg" {
  for_each = { for key, value in local.security_groups : key => value }

  vpc_id = aws_vpc.main.id
  name = title(replace(each.key, "_", " "))
}