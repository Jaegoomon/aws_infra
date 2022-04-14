resource "aws_iam_role" "codedeploy_role" {
  name                = "codedeploy_role"
  assume_role_policy  = "${var.codedeploy_role}"
}

resource "aws_iam_role_policy" "codedeploy_role_policy" {
  name   = "codedeploy_role_policy"
  policy = "${var.codedeploy_role_policy}"
  role   = aws_iam_role.codedeploy_role.id
}