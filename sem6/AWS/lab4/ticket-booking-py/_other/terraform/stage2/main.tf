terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Default VPC & subnets
data "aws_vpcs" "default" {
  filter { 
    name = "isDefault"
    values = ["true"]
  }
}
data "aws_subnets" "default" {
  filter { 
    name = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]] 
  }
}

# 2. Security Group dla wszystkich mikroserwisów
resource "aws_security_group" "svc_sg" {
  name        = "microservices-sg"
  description = "Allow HTTP to all microservices"
  vpc_id      = data.aws_vpcs.default.ids[0]

  ingress {
    from_port   = 8000
    to_port     = 8004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Pobranie najnowszego Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 4. EC2 dla każdego serwisu
resource "aws_instance" "svc" {
  for_each = toset(var.services)

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.svc_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "${each.key}-service"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user

    # pull and run container
    docker pull zawodev/${each.key}-service:latest
    docker rm -f ${each.key} || true
    docker run -d --name ${each.key} -p ${lookup(var.service_ports, each.key)}:${lookup(var.service_ports, each.key)} zawodev/${each.key}-service:latest
  EOF
}
