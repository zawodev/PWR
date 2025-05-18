output "alb_dns" {
  description = "DNS name Application Load Balancera"
  value       = aws_lb.alb.dns_name
}

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.cluster.id
}

output "service_ids" {
  description = "Mapowanie usługa → ECS Service ID"
  value = {
    for name, svc in aws_ecs_service.svc :
    name => svc.id
  }
}
