# LoadBalancer
resource "aws_lb" "ecs" {
  name                = "${var.ecs_cluster_name}"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.ecs.id]
  subnets             = "${var.public_subnet_ids}"
}

# Target group
resource "aws_lb_target_group" "blue" {
  name      = "${var.ecs_cluster_name}-blue"
  port      = 8000
  protocol  = local.http_protocol
  vpc_id    = "${var.vpc_id}"
}

resource "aws_lb_target_group" "green" {
  name      = "${var.ecs_cluster_name}-green"
  port      = 8001
  protocol  = local.http_protocol
  vpc_id    = "${var.vpc_id}"
}

# Listener
resource "aws_lb_listener" "http_blue" {
  load_balancer_arn = aws_lb.ecs.arn 
  port              = var.blue_port
  protocol          = local.http_protocol

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  } 
}

resource "aws_lb_listener" "http_green" {
  load_balancer_arn = aws_lb.ecs.arn 
  port              = var.green_port
  protocol          = local.http_protocol

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  } 
}