data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_vpc" "default" {
  default = true
}

# Public half of the key created on the laptop; the private key never leaves it
resource "aws_key_pair" "day15" {
  key_name   = "day15-aws"
  public_key = file(pathexpand("~/.ssh/day15-aws.pub"))
}

locals {
  # Every inbound port is opened to my IP only
  ingress_ports = {
    ssh           = 22
    http          = 80
    node_exporter = 9100
  }
}

resource "aws_security_group" "web" {
  name        = "day15-tf-sg"
  description = "SSH, HTTP and node_exporter from my IP only - managed by Terraform"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "from_me" {
  for_each          = local.ingress_ports
  security_group_id = aws_security_group.web.id
  description       = "${each.key} from my IP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value
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
  key_name                    = aws_key_pair.day15.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "day15-server"
  }
}
