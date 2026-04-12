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

// plugin terraforma do konkretnej chmury
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "region aws"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "nazwa projektu (prefixdla zasobów aws) "
  type        = string
  default     = "simple-chat-v3"
}

variable "db_name" {
  description = "nazwa bazy danych rds"
  type        = string
  default     = "chatdb"
}

variable "db_username" {
  description = "login admina dla bazy rds"
  type        = string
  default     = "chatadmin"
}

variable "db_password" {
  description = "passy do bazy rds (jak puste, terraform wygeneruje sam)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "eb_solution_stack_name" {
  description = "elastic beanstalk"
  type        = string
  default     = "64bit Amazon Linux 2 v4.7.0 running Docker"
}

variable "frontend_origin" {
  description = "dozwolony origin frontendu dla CORS w backendzie"
  type        = string
  default     = "*"
}

// zmienne wejśćiowe
variable "eb_instance_profile_name" {
  description = "nazwa istniejącego 'instance profile' dla ec2 w Elastic Beanstalk"
  type        = string
  default     = "LabInstanceProfile"
}

//zmienne pomocnicze
locals {
  db_password_effective = var.db_password != "" ? var.db_password : random_password.db_password.result
}

//zasób tworzony w aws
resource "random_id" "suffix" {
  byte_length = 3
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#%^*-_=+"
}

resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_id.suffix.hex}"
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
}

resource "aws_security_group_rule" "rds_postgres_ingress" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = tolist(aws_db_instance.chat.vpc_security_group_ids)[0]
  description       = "Allow PostgreSQL access for backend in Academy sandbox"
}

resource "aws_elastic_beanstalk_application" "backend" {
  name        = "${var.project_name}-backend"
  description = "Backend FastAPI app"
}

resource "aws_elastic_beanstalk_environment" "backend" {
  name                = "${var.project_name}-backend-env"
  application         = aws_elastic_beanstalk_application.backend.name
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
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = "postgresql://${var.db_username}:${local.db_password_effective}@${aws_db_instance.chat.address}:5432/${var.db_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "S3_BUCKET"
    value     = aws_s3_bucket.media.bucket
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COGNITO_REGION"
    value     = var.aws_region
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COGNITO_USER_POOL_ID"
    value     = aws_cognito_user_pool.chat_users.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COGNITO_CLIENT_ID"
    value     = aws_cognito_user_pool_client.chat_app_client.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FRONTEND_ORIGIN"
    value     = var.frontend_origin
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

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  alarm_description   = "RDS CPU above 80%"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.chat.id
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "RDS CPU"
          region  = var.aws_region
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.chat.id]]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Beanstalk Environment Health"
          region = var.aws_region
          view   = "timeSeries"
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/ElasticBeanstalk", "EnvironmentHealth", "EnvironmentName", aws_elastic_beanstalk_environment.backend.name, "ApplicationName", aws_elastic_beanstalk_application.backend.name],
            ["AWS/ElasticBeanstalk", "EnvironmentHealth", "EnvironmentName", aws_elastic_beanstalk_environment.frontend.name, "ApplicationName", aws_elastic_beanstalk_application.frontend.name]
          ]
        }
      }
    ]
  })
}

//wyjściowe wartości wypisywane po apply
output "frontend_url" {
  value = "http://${aws_elastic_beanstalk_environment.frontend.cname}"
}

output "backend_url" {
  value = "http://${aws_elastic_beanstalk_environment.backend.cname}"
}

output "s3_media_bucket" {
  value = aws_s3_bucket.media.bucket
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
