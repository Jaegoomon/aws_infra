module ecs {
  source = "../modules/ecs"

  ecs_cluster_name = "pikurate-dashboard-terraform"

  image_id          = "ami-04c0ac9468f496b8e"
  instance_type     = "t3.micro"
  instance_profile  = aws_iam_instance_profile.ecs.name
  key_name          = module.vpc.key_name

  subnet_ids    = module.vpc.private_subnet_ids
  autoscale_sg  = [module.vpc.ssh_sg_id, aws_security_group.autoscale.id]
  
  autoscale_min     = 1
  autoscale_max     = 3
  autoscale_desired = 1
}

# Security group
resource "aws_security_group" "autoscale" {
  name        = "autoscale"
  description = "Allow autoscale group instances traffix"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "autoscale security sg"
  }
}

# # Task definition
# resource "aws_ecs_task_definition" "task_definition" {
#   family                = "worker"
#   container_definitions = file("../ecs_demo.json.tpl")
# }

# Service
resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = module.ecs.cluster_id
  task_definition = ""
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name = "web"
    container_port = 80
  }
}