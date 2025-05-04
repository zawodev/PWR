variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "Unikalny identyfikator instancji RDS"
  type        = string
  default     = "my-db-cluster"
}

variable "master_username" {
  description = "Master username dla PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password dla PostgreSQL"
  type        = string
}

variable "instance_class" {
  description = "Klasa instancji RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Rozmiar pamięci w GB"
  type        = number
  default     = 20
}

variable "rabbitmq_instance_type" {
  description = "Typ instancji EC2 dla RabbitMQ"
  type        = string
  default     = "t3.micro"
}
