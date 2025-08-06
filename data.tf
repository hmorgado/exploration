data "aws_vpc" "main" {
  id = aws_vpc.main.id
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

data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = ["${local.env_name}-subnet-public1-us-west-1a"]
  }
}

data "aws_subnet" "public_c" {
  filter {
    name   = "tag:Name"
    values = ["${local.env_name}-subnet-public2-us-west-1c"]
  }
}