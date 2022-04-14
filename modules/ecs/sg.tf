# Security group
resource "aws_security_group" "autoscale" {
  name        = "${var.ecs_cluster_name}"
  description = "Allow autoscale group instances traffix"
  vpc_id      = "${var.vpc_id}"

  dynamic "ingress" {
    for_each = toset(var.ingress_ports)

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = local.tcp_protocol
      cidr_blocks = local.all_ips
    }
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s", var.ecs_cluster_name)
  }))}"
}