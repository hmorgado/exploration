resource "aws_flow_log" "flow_log" {
  vpc_id = aws_vpc.main.id

  log_destination_type     = "cloud-watch-logs" # default
  log_destination          = aws_cloudwatch_log_group.flow_log_group.arn
  max_aggregation_interval = 60
  traffic_type             = "ALL"
  tags                     = { "Name" = "Public_traffic" }
  iam_role_arn             = aws_iam_role.flow_log.arn

  depends_on = [aws_cloudwatch_log_group.flow_log_group]
}

resource "aws_iam_role" "flow_log" {
  name               = "VPC_Flow_Logs_Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "logs" {
  name   = "Logs_Policy"
  role   = aws_iam_role.flow_log.id
  policy = data.aws_iam_policy_document.logs_actions.json
}

data "aws_iam_policy_document" "logs_actions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "PUBLIC_TRAFFIC"
  tags = { "Name" = "PUBLIC_TRAFFIC" }
}