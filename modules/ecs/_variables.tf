variable ecs_cluster_name {
  type        = string
  description = "ECS cluster name"
}

variable image_id {
  type        = string
  default     = "ami-04c0ac9468f496b8e"
  description = "EC2 instance image"
}

variable instance_type {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable private_subnet_ids {
  type        = list
  description = "Subnets for autoscaling group instances"
}

variable public_subnet_ids {
  type        = list
  description = "Subnets for load balancer"
}

variable key_name {
  type        = string
  description = "Key name for SSH connection"
}

variable autoscale_min {
  description = "Minimum autoscale (number of EC2)"
  default     = "1"
}

variable autoscale_max {
  description = "Maximum autoscale (number of EC2)"
  default     = "10"
}

variable autoscale_desired {
  description = "Desired autoscale (number of EC2)"
  default     = "2"
}

variable target_capacity {
  type        = number
  default     = 100
  description = "Target capacity for ecs capcity provider"
}

variable ingress_ports {
  type        = list
  description = "Ingress ports for autoscale group"
}

variable ecs_role {
  type        = string
  description = "description"
}

variable ecs_instance_role_policy {
  type        = string
  description = "description"
}

variable ecs_service_role_policy {
  type        = string
  description = "description"
}

variable vpc_id {
  type        = string
  description = "description"
}

variable tags {
  type        = map
  description = "Tag map for all resources"
}