variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nazwa ECS Cluster"
  type        = string
  default     = "microservices-cluster"
}

variable "service_ports" {
  description = "Porty poszczególnych usług"
  type = map(number)
  default = {
    booking      = 8000
    availability = 8001
    payment      = 8002
    ticketing    = 8003
    notification = 8004
  }
}

variable "alb_name" {
  description = "Nazwa Application Load Balancera"
  type        = string
  default     = "ms-alb"
}

variable "tg_name" {
  description = "Nazwa Target Group"
  type        = string
  default     = "ms-tg"
}

variable "execution_role_name" {
  description = "Istniejąca rola IAM ECS Task Execution"
  type        = string
  default     = "AWSServiceRoleForECS"
}
