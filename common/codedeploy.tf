module codedeploy {
  source = "../modules/codedeploy"

  app_name = "demo"

  deployment_config_name = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = aws_ecs_service.worker.name

  # IAM options
  codedeploy_role           = file("../iam/codedeploy_role.json")
  codedeploy_role_policy    = file("../iam/codedeploy_role_policy.json")
  
  # VPC options
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids

  blue_port   = 80
  green_port  = 81

  tags = {
    "TerraformManaged" = "true"
  }
}

# Task definition
resource "aws_ecs_task_definition" "worker" {
  family                = "worker"
  container_definitions = file("../ecs_demo.json.tpl")
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = module.codedeploy.blue_target_group
    container_name = "simple-python-app"
    container_port = 80
  }
}