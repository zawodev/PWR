terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "micro-chat"
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "chatdb"
}

variable "db_username" {
  description = "RDS admin username"
  type        = string
  default     = "chatadmin"
}

variable "db_password" {
  description = "RDS password (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "eb_solution_stack_name" {
  description = "Elastic Beanstalk solution stack"
  type        = string
  default     = "64bit Amazon Linux 2 v4.7.0 running Docker"
}

variable "eb_instance_profile_name" {
  description = "Existing instance profile name for EB (AWS Academy uses LabInstanceProfile)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "frontend_origin" {
  description = "Allowed CORS origin for APIs"
  type        = string
  default     = "*"
}

variable "notification_email" {
  type        = string
  default     = "272644@student.pwr.edu.pl"
}

variable "auth_image" {
  description = "Auth service image (optional override)"
  type        = string
  default     = ""
}

variable "chat_image" {
  description = "Chat service image (optional override)"
  type        = string
  default     = ""
}

variable "media_image" {
  description = "Media service image (optional override)"
  type        = string
  default     = ""
}

variable "notification_image" {
  description = "Notification service image (optional override)"
  type        = string
  default     = ""
}

variable "notification_shared_secret" {
  type        = string
  default     = ""
}

variable "ecs_task_execution_role_name" {
  description = "Existing IAM role name for ECS task execution (AWS Academy uses LabRole)"
  type        = string
  default     = "LabRole"
}

variable "ecs_task_role_name" {
  description = "Existing IAM role name for ECS task runtime (AWS Academy uses LabRole)"
  type        = string
  default     = "LabRole"
}

variable "ecs_task_execution_role_arn" {
  description = "Optional IAM role ARN for ECS task execution (overrides role name)"
  type        = string
  default     = ""
}

variable "ecs_task_role_arn" {
  description = "Optional IAM role ARN for ECS task runtime (overrides role name)"
  type        = string
  default     = ""
}

data "aws_caller_identity" "current" {}

locals {
  db_password_effective = var.db_password != "" ? var.db_password : random_password.db_password.result
  ecs_task_execution_role_arn = var.ecs_task_execution_role_arn != "" ? var.ecs_task_execution_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_execution_role_name}"
  ecs_task_role_arn           = var.ecs_task_role_arn != "" ? var.ecs_task_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ecs_task_role_name}"
  notification_shared_secret_effective = var.notification_shared_secret != "" ? var.notification_shared_secret : random_password.notification_secret.result
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#%^*-_=+"
}

resource "random_password" "notification_secret" {
  length  = 32
  special = false
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "auth_users" {
  name         = "${var.project_name}-auth-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }
}

resource "aws_dynamodb_table" "media_metadata" {
  name         = "${var.project_name}-media-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "media_id"

  attribute {
    name = "media_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "notifications" {
  name         = "${var.project_name}-notifications"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "notification_id"

  attribute {
    name = "notification_id"
    type = "S"
  }
}

resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-notifications"
}

resource "aws_sns_topic_subscription" "notifications_email" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cognito_user_pool" "chat_users" {
  name                = "${var.project_name}-users"
  mfa_configuration   = "OFF"
  deletion_protection = "INACTIVE"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

resource "aws_cognito_user_pool_client" "chat_app_client" {
  name         = "${var.project_name}-app-client"
  user_pool_id = aws_cognito_user_pool.chat_users.id

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_elastic_beanstalk_application" "frontend" {
  name        = "${var.project_name}-frontend"
  description = "Frontend React app"
}

resource "aws_elastic_beanstalk_environment" "frontend" {
  name                = "${var.project_name}-frontend-env"
  application         = aws_elastic_beanstalk_application.frontend.name
  solution_stack_name = var.eb_solution_stack_name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.eb_instance_profile_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "14"
  }
}

resource "aws_db_subnet_group" "chat" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB security group"
  vpc_id      = data.aws_vpc.default.id

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

resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-ecs-sg"
  description = "ECS service security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "RDS security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "chat" {
  identifier            = "${var.project_name}-db"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "postgres"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  username              = var.db_username
  password              = local.db_password_effective
  publicly_accessible   = true
  skip_final_snapshot   = true
  deletion_protection   = false
  db_subnet_group_name  = aws_db_subnet_group.chat.name
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
}

resource "aws_ecr_repository" "auth" {
  name = "${var.project_name}-auth"
  force_delete = true
}

resource "aws_ecr_repository" "chat" {
  name = "${var.project_name}-chat"
  force_delete = true
}

resource "aws_ecr_repository" "media" {
  name = "${var.project_name}-media"
  force_delete = true
}

resource "aws_ecr_repository" "notification" {
  name = "${var.project_name}-notification"
  force_delete = true
}

locals {
  auth_image_effective = var.auth_image != "" ? var.auth_image : "${aws_ecr_repository.auth.repository_url}:latest"
  chat_image_effective = var.chat_image != "" ? var.chat_image : "${aws_ecr_repository.chat.repository_url}:latest"
  media_image_effective = var.media_image != "" ? var.media_image : "${aws_ecr_repository.media.repository_url}:latest"
  notification_image_effective = var.notification_image != "" ? var.notification_image : "${aws_ecr_repository.notification.repository_url}:latest"
}


resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/${var.project_name}/auth"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "chat" {
  name              = "/ecs/${var.project_name}/chat"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "media" {
  name              = "/ecs/${var.project_name}/media"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "notification" {
  name              = "/ecs/${var.project_name}/notification"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "auth" {
  name        = "${var.project_name}-auth-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/api/auth/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "chat" {
  name        = "${var.project_name}-chat-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/api/chats/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "media" {
  name        = "${var.project_name}-media-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/api/media/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "notification" {
  name        = "${var.project_name}-notification-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/api/notifications/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat.arn
  }
}

resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/api/auth*"]
    }
  }
}

resource "aws_lb_listener_rule" "media" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.media.arn
  }

  condition {
    path_pattern {
      values = ["/api/media*"]
    }
  }
}

resource "aws_lb_listener_rule" "notification" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notification.arn
  }

  condition {
    path_pattern {
      values = ["/api/notifications*"]
    }
  }
}

resource "aws_lb_listener_rule" "chat" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat.arn
  }

  condition {
    path_pattern {
      values = ["/api/chats*", "/api/messages*"]
    }
  }
}

resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project_name}-auth"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.ecs_task_execution_role_arn
  task_role_arn            = local.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "auth-service"
      image     = local.auth_image_effective
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "COGNITO_REGION", value = var.aws_region },
        { name = "COGNITO_USER_POOL_ID", value = aws_cognito_user_pool.chat_users.id },
        { name = "COGNITO_CLIENT_ID", value = aws_cognito_user_pool_client.chat_app_client.id },
        { name = "AUTH_TABLE_NAME", value = aws_dynamodb_table.auth_users.name },
        { name = "FRONTEND_ORIGIN", value = var.frontend_origin }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.auth.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "chat" {
  family                   = "${var.project_name}-chat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.ecs_task_execution_role_arn
  task_role_arn            = local.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "chat-service"
      image     = local.chat_image_effective
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DATABASE_URL", value = "postgresql://${var.db_username}:${local.db_password_effective}@${aws_db_instance.chat.address}:5432/${var.db_name}" },
        { name = "FRONTEND_ORIGIN", value = var.frontend_origin },
        { name = "MEDIA_SERVICE_URL", value = "http://${aws_lb.main.dns_name}" },
        { name = "NOTIFICATION_SERVICE_URL", value = "http://${aws_lb.main.dns_name}" },
        { name = "NOTIFICATION_SHARED_SECRET", value = local.notification_shared_secret_effective },
        { name = "COGNITO_REGION", value = var.aws_region },
        { name = "COGNITO_USER_POOL_ID", value = aws_cognito_user_pool.chat_users.id },
        { name = "COGNITO_CLIENT_ID", value = aws_cognito_user_pool_client.chat_app_client.id }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.chat.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "media" {
  family                   = "${var.project_name}-media"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.ecs_task_execution_role_arn
  task_role_arn            = local.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "media-service"
      image     = local.media_image_effective
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "S3_BUCKET", value = aws_s3_bucket.media.bucket },
        { name = "MEDIA_TABLE_NAME", value = aws_dynamodb_table.media_metadata.name },
        { name = "MAX_FILE_SIZE_BYTES", value = "10485760" },
        { name = "FRONTEND_ORIGIN", value = var.frontend_origin },
        { name = "COGNITO_REGION", value = var.aws_region },
        { name = "COGNITO_USER_POOL_ID", value = aws_cognito_user_pool.chat_users.id },
        { name = "COGNITO_CLIENT_ID", value = aws_cognito_user_pool_client.chat_app_client.id }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.media.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "notification" {
  family                   = "${var.project_name}-notification"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = local.ecs_task_execution_role_arn
  task_role_arn            = local.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "notification-service"
      image     = local.notification_image_effective
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "SNS_TOPIC_ARN", value = aws_sns_topic.notifications.arn },
        { name = "NOTIFICATIONS_TABLE_NAME", value = aws_dynamodb_table.notifications.name },
        { name = "NOTIFICATION_SHARED_SECRET", value = local.notification_shared_secret_effective },
        { name = "FRONTEND_ORIGIN", value = var.frontend_origin },
        { name = "COGNITO_REGION", value = var.aws_region },
        { name = "COGNITO_USER_POOL_ID", value = aws_cognito_user_pool.chat_users.id },
        { name = "COGNITO_CLIENT_ID", value = aws_cognito_user_pool_client.chat_app_client.id }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.notification.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "auth" {
  name            = "${var.project_name}-auth"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth.arn
    container_name   = "auth-service"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "chat" {
  name            = "${var.project_name}-chat"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.chat.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.chat.arn
    container_name   = "chat-service"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "media" {
  name            = "${var.project_name}-media"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.media.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.media.arn
    container_name   = "media-service"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "notification" {
  name            = "${var.project_name}-notification"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notification.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.notification.arn
    container_name   = "notification-service"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_appautoscaling_target" "auth" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.auth.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "auth_cpu" {
  name               = "${var.project_name}-auth-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auth.resource_id
  scalable_dimension = aws_appautoscaling_target.auth.scalable_dimension
  service_namespace  = aws_appautoscaling_target.auth.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "chat" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.chat.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "chat_cpu" {
  name               = "${var.project_name}-chat-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.chat.resource_id
  scalable_dimension = aws_appautoscaling_target.chat.scalable_dimension
  service_namespace  = aws_appautoscaling_target.chat.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "media" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.media.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "media_cpu" {
  name               = "${var.project_name}-media-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.media.resource_id
  scalable_dimension = aws_appautoscaling_target.media.scalable_dimension
  service_namespace  = aws_appautoscaling_target.media.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "notification" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.notification.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "notification_cpu" {
  name               = "${var.project_name}-notification-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.notification.resource_id
  scalable_dimension = aws_appautoscaling_target.notification.scalable_dimension
  service_namespace  = aws_appautoscaling_target.notification.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

output "alb_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "frontend_url" {
  value = "http://${aws_elastic_beanstalk_environment.frontend.cname}"
}

output "s3_media_bucket" {
  value = aws_s3_bucket.media.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.notifications.arn
}

output "auth_table_name" {
  value = aws_dynamodb_table.auth_users.name
}

output "media_table_name" {
  value = aws_dynamodb_table.media_metadata.name
}

output "notifications_table_name" {
  value = aws_dynamodb_table.notifications.name
}

output "rds_endpoint" {
  value = aws_db_instance.chat.address
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.chat_users.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.chat_app_client.id
}

output "auth_ecr_repo" {
  value = aws_ecr_repository.auth.repository_url
}

output "chat_ecr_repo" {
  value = aws_ecr_repository.chat.repository_url
}

output "media_ecr_repo" {
  value = aws_ecr_repository.media.repository_url
}

output "notification_ecr_repo" {
  value = aws_ecr_repository.notification.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_auth_name" {
  value = aws_ecs_service.auth.name
}

output "ecs_service_chat_name" {
  value = aws_ecs_service.chat.name
}

output "ecs_service_media_name" {
  value = aws_ecs_service.media.name
}

output "ecs_service_notification_name" {
  value = aws_ecs_service.notification.name
}

output "frontend_app_name" {
  value = aws_elastic_beanstalk_application.frontend.name
}

output "frontend_env_name" {
  value = aws_elastic_beanstalk_environment.frontend.name
}
