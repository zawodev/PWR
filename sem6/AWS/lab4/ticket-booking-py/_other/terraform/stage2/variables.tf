variable "aws_region" {
  description = "Region AWS, np. us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nazwa klastra ECS"
  type        = string
  default     = "microservices-cluster"
}

variable "docker_registry" {
  description = "URL Twojego rejestru Docker (np. zawodev/booking-service)"
  type        = string
  default     = "zawodev"
}

variable "postgres_endpoint" {
  description = "Endpoint bazy PostgreSQL (z stage1)"
  type        = string
}

variable "rabbitmq_endpoint" {
  description = "Endpoint/host RabbitMQ (z stage1)"
  type        = string
}
