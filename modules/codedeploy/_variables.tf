variable app_name {
  type        = string
  description = "description"
}

variable codedeploy_role {
  type        = string
  description = "description"
}

variable codedeploy_role_policy {
  type        = string
  description = "description"
}

variable deployment_config_name {
  type        = string
  description = "description"
}

variable vpc_id {
  type        = string
  description = "description"
}

variable public_subnet_ids {
  type        = list
  description = "Subnets for load balancer"
}

variable blue_port {
  type        = number
  description = "description"
}

variable green_port {
  type        = number
  description = "description"
}

variable ecs_cluster_name {
  type        = string
  description = "description"
}

variable ecs_service_name {
  type        = string
  description = "description"
}

variable tags {
  type        = map
  description = "Tag map for all resources"
}
