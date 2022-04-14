resource "aws_security_group" "ecs" {
  name        = "${var.ecs_cluster_name}_load_balancer"
  description = "Allow load balancer traffix"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = var.blue_port
    to_port     = var.blue_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  ingress {
    from_port   = var.green_port
    to_port     = var.green_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-alb", var.ecs_cluster_name)
  }))}"
}