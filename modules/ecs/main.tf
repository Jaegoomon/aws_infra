# ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.ecs_cluster_name}"
}

# Autoscaling group
resource "aws_launch_configuration" "this" {
  name                        = "${var.ecs_cluster_name}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = [aws_security_group.autoscale.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = "${var.key_name}"
  associate_public_ip_address = false
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "this" {
  name                 = "${var.ecs_cluster_name}_auto_scaling_group"
  min_size             = "${var.autoscale_min}"
  max_size             = "${var.autoscale_max}"
  desired_capacity     = "${var.autoscale_desired}"
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier  = "${var.private_subnet_ids}"

  protect_from_scale_in = false

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = "${var.ecs_cluster_name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = "${var.ecs_cluster_name}"

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}