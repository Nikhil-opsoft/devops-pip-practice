# Latest Amazon Linux 2023 image, looked up at plan time (no hard-coded AMI ID)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web" {
  name        = "day14-tf-sg"
  description = "HTTP from my IP only - managed by Terraform"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "http_from_me" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from my IP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.web.id
  description       = "Outbound for package installs"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-USERDATA
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Day 14 - provisioned by Terraform</h1><p>$(hostname)</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  USERDATA

  tags = {
    Name = "day14-tf-server"
  }
}
