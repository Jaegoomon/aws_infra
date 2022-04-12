resource "aws_iam_role" "ecs_host_role" {
  name               = "ecs_host_role"
  assume_role_policy = file("../iam/ecs_role.json")
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy"
  policy = file("../iam/ecs_instance_role_policy.json")
  role   = aws_iam_role.ecs_host_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = file("../iam/ecs_role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = file("../iam/ecs_service_role_policy.json")
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_host_role.name
}

resource "aws_iam_role" "codedeploy_role" {
  name                = "codedeploy_role"
  assume_role_policy  = file("../iam/codedeploy_role.json")
}

resource "aws_iam_role_policy" "codedeploy_role_policy" {
  name   = "codedeploy_role_policy"
  policy = file("../iam/codedeploy_role_policy.json")
  role   = aws_iam_role.codedeploy_role.id
}

# resource "aws_iam_role_policy_attachment" "test-attach" {
#   role       = aws_iam_role.codedeploy_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
# }