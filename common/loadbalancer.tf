# Security group
resource "aws_security_group" "ecs" {
  name        = "load_balancer"
  description = "Allow load balancer traffix"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 81
    to_port     = 81
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
    Name = "load balancer sg"
  }
}

# Target group
resource "aws_lb_target_group" "blue" {
  name      = "ecs-blue"
  port      = 8000
  protocol  = "HTTP"
  vpc_id    = module.vpc.vpc_id
  
  tags = {
    Name = "main"
  }
}

resource "aws_lb_target_group" "green" {
  name      = "ecs-green"
  port      = 8001
  protocol  = "HTTP"
  vpc_id    = module.vpc.vpc_id
  
  tags = {
    Name = "main"
  }
}

# LoadBalancer
resource "aws_lb" "ecs" {
  name                = "ecs-demo"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.ecs.id]
  subnets             = module.vpc.public_subnet_ids

  tags = {
    Environment = "main",
    Name = "prod"
  }
}

# Listener
resource "aws_lb_listener" "http_blue" {
  load_balancer_arn = aws_lb.ecs.arn 
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  } 
}

resource "aws_lb_listener" "http_green" {
  load_balancer_arn = aws_lb.ecs.arn 
  port              = 81
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  } 
}