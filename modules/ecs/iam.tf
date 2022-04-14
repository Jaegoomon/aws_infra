# ECS IAM
resource "aws_iam_role" "ecs_host_role" {
  name               = "ecs_host_role"
  assume_role_policy = "${var.ecs_role}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy"
  policy = "${var.ecs_instance_role_policy}"
  role   = aws_iam_role.ecs_host_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = "${var.ecs_role}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${var.ecs_service_role_policy}"
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_host_role.name
}