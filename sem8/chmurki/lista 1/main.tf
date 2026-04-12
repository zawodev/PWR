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
  description = "Prefix for all resources"
  type        = string
  default     = "simple-chat"
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
  description = "RDS admin password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "eb_solution_stack_name" {
  description = "Elastic Beanstalk Docker solution stack name (set according to your region/account)"
  type        = string
  default     = "64bit Amazon Linux 2 v4.7.0 running Docker"
}

variable "frontend_origin" {
  description = "Allowed frontend origin for backend CORS"
  type        = string
  default     = "*"
}

variable "backend_api_url" {
  description = "Backend URL injected into frontend"
  type        = string
  default     = ""
}

variable "public_ingress_cidr" {
  description = "Public ingress CIDR for demo deployment"
  type        = string
  default     = "0.0.0.0/0"
}

variable "eb_service_role_name" {
  description = "Existing Elastic Beanstalk service role name"
  type        = string
  default     = "aws-elasticbeanstalk-service-role"
}

variable "eb_instance_profile_name" {
  description = "Existing EC2 instance profile name for Elastic Beanstalk"
  type        = string
  default     = "LabInstanceProfile"
}

locals {
  name_prefix           = var.project_name
  db_password_effective = var.db_password != "" ? var.db_password : random_password.db_password.result
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#%^*-_=+"
}

resource "aws_s3_bucket" "media" {
  bucket = "${local.name_prefix}-media-${random_id.suffix.hex}"
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
  identifier            = "${local.name_prefix}-db"
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
  name        = "${local.name_prefix}-backend"
  description = "Backend FastAPI app"
}

resource "aws_elastic_beanstalk_environment" "backend" {
  name                = "${local.name_prefix}-backend-env"
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
  name        = "${local.name_prefix}-frontend"
  description = "Frontend React app"
}

resource "aws_elastic_beanstalk_environment" "frontend" {
  name                = "${local.name_prefix}-frontend-env"
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
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "VITE_API_URL"
    value     = var.backend_api_url
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
  name                = "${local.name_prefix}-users"
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
  name         = "${local.name_prefix}-app-client"
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
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
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
  dashboard_name = "${local.name_prefix}-dashboard"

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
