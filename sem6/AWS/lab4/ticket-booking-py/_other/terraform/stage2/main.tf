terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# ========== datasource'y VPC, subnet, default SG ==========
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

# ========== 1. Security Group dla ALB ==========
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = data.aws_vpcs.default.ids[0]

  ingress {
    from_port   = 80
    to_port     = 80
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

# ========== 2. Security Group dla Fargate ==========
resource "aws_security_group" "svc_sg" {
  name        = "fargate-services-sg"
  description = "Allow ALB to reach Fargate tasks"
  vpc_id      = data.aws_vpcs.default.ids[0]

  ingress {
    from_port       = 8000
    to_port         = 8004
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ========== 3. ECS Cluster ==========
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# ========== 4. ALB + Listener + TG ==========
resource "aws_lb" "alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
  name        = var.tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpcs.default.ids[0]
  target_type = "ip"

  health_check {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ========== 5. IAM Role ==========
data "aws_iam_role" "exec_role" {
  name = var.execution_role_name
}

# ========== 6. Task Definitions & Services ==========
locals {
  services = ["booking","availability","payment","ticketing","notification"]
}

resource "aws_ecs_task_definition" "tasks" {
  for_each                 = toset(local.services)
  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.exec_role.arn

  container_definitions = jsonencode([{
    name      = each.key
    image     = "zawodev/${each.key}-service:latest"
    portMappings = [{
      containerPort = lookup(var.service_ports, each.key)
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${each.key}"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = each.key
      }
    }
  }])
}

resource "aws_ecs_service" "svc" {
  for_each        = aws_ecs_task_definition.tasks
  name            = each.key
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = each.value.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.svc_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = each.key
    container_port   = lookup(var.service_ports, each.key)
  }

  depends_on = [aws_lb_listener.http]
}
