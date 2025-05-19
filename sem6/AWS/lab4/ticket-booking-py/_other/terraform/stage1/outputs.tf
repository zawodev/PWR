output "postgres_endpoint" {
  description = "Endpoint instancji RDS PostgreSQL"
  value       = aws_db_instance.postgres.address # lub .endpoint idk
}

output "postgres_databases" {
  description = "Lista utworzonych dodatkowych baz"
  value       = local.db_names
}

output "rabbitmq_endpoint" {
  description = "Publiczny adres instancji RabbitMQ"
  value       = aws_instance.rabbitmq.public_ip
}
