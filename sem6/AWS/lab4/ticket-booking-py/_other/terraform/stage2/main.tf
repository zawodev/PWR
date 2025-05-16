terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

####################################
# 1. ECS Cluster
####################################
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

####################################
# 2. IAM Role for Fargate tasks
####################################
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

####################################
# 3. Security Group for services
####################################
data "aws_default_vpc" "default" {}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_default_vpc.default.id]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "ecs-services-sg"
  vpc_id      = data.aws_default_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
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

####################################
# 4. Task Definitions & Services
####################################
locals {
  services = [
    {
      name  = "booking"
      image = "${var.docker_registry}/booking-service:latest"
      port  = 8000
    },
    {
      name  = "availability"
      image = "${var.docker_registry}/availability-service:latest"
      port  = 8001
    },
    {
      name  = "payment"
      image = "${var.docker_registry}/payment-service:latest"
      port  = 8002
    },
    {
      name  = "ticketing"
      image = "${var.docker_registry}/ticketing-service:latest"
      port  = 8003
    },
    {
      name  = "notification"
      image = "${var.docker_registry}/notification-service:latest"
      port  = 8004
    },
  ]
}

# Task definitions
resource "aws_ecs_task_definition" "tasks" {
  for_each = { for svc in local.services : svc.name => svc }

  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.image
      essential = true

      portMappings = [
        {
          containerPort = each.value.port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.postgres_endpoint}:5432/${each.key}"
        },
        {
          name  = "RABBITMQ_URL"
          value = "amqp://guest:guest@${var.rabbitmq_endpoint}:5672/"
        }
      ]
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "services" {
  for_each        = aws_ecs_task_definition.tasks
  name            = each.key
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = each.value.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_policy]
}
