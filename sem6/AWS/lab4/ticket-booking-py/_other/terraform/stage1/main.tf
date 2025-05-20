terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.15"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# tworzenie domyślnego VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

# pobranie subnetów domyślnej VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# security group dla RDS PostgreSQL
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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

# security group dla RabbitMQ
resource "aws_security_group" "rabbit_sg" {
  name        = "rabbitmq-sg"
  description = "Allow RabbitMQ"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 15672
    to_port     = 15672
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

# grupa subnetów dla RDS
resource "aws_db_subnet_group" "default" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.db_identifier}-db-subnet-group"
  }
}

# pojedyncza instancja RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = var.db_identifier
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = "postgres"
  username               = var.master_username
  password               = var.master_password
  port                   = 5432
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# opóźniam żeby endpoint DNS był gotowy
resource "time_sleep" "wait_db" {
  depends_on      = [aws_db_instance.postgres]
  create_duration = "60s"
}

# provider PostgreSQL łączy się do endpointu RDS
provider "postgresql" {
  host            = aws_db_instance.postgres.address
  port            = aws_db_instance.postgres.port
  username        = var.master_username
  password        = var.master_password
  sslmode         = "require"
  connect_timeout = 15
}

# nazwy baz danych (mogłyby być w zmiennych ale są stałe)
locals {
  db_names = ["booking", "availability", "notification", "payment", "ticketing"]
}

# tworzenie pięciu baz danych
resource "postgresql_database" "databases" {
  for_each = toset(local.db_names)
  name     = each.value
  owner    = var.master_username

  depends_on = [
    time_sleep.wait_db
  ]
}

# wyszukanie najnowszego amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# RabbitMQ na EC2
resource "aws_instance" "rabbitmq" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.rabbitmq_instance_type
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.rabbit_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install epel -y
              yum install rabbitmq-server -y
              systemctl enable rabbitmq-server
              systemctl start rabbitmq-server
              EOF

  tags = {
    Name = "rabbitmq-broker"
  }
}