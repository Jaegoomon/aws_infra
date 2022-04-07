# ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.ecs_cluster_name}"
}

# Autoscaling group
resource "aws_launch_configuration" "this" {
  name                        = "${var.ecs_cluster_name}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = "${var.autoscale_sg}"
  iam_instance_profile        = "${var.instance_profile}"
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
  vpc_zone_identifier  = "${var.subnet_ids}"
}