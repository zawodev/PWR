output "ecs_cluster_id" {
  description = "ID utworzonego klastra ECS"
  value       = aws_ecs_cluster.cluster.id
}

output "ecs_service_names" {
  description = "Lista nazw uruchomionych usług"
  value       = [for svc in aws_ecs_service.services : svc.name]
}
