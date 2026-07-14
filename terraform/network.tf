data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"

    values = [
      data.aws_vpc.default.id
    ]
  }
}

resource "aws_security_group" "app" {
  name        = "cloud-devops-cicd-app"
  description = "Allow public HTTP access to the containerised application"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app.id

  description = "Allow inbound HTTP"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id

  description = "Allow outbound connectivity"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
