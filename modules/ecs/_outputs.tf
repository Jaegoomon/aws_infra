output cluster_id {
  value       = aws_ecs_cluster.this.id
  description = "ECS cluster ID"
}

output cluster_name {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}
