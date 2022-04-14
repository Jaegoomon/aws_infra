module ecs {
  source = "../modules/ecs"

  ecs_cluster_name = "demo"

  # IAM options
  ecs_role                  = file("../iam/ecs_role.json")
  ecs_instance_role_policy  = file("../iam/ecs_instance_role_policy.json")
  ecs_service_role_policy   = file("../iam/ecs_service_role_policy.json")

  # VPC options
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids

  ingress_ports = [22, 80, 3000]
  
  # EC2 instance options(Autoscaling EC2)
  image_id          = "ami-04c0ac9468f496b8e"
  instance_type     = "t3.micro"
  key_name          = module.vpc.key_name

  # Autoscale options
  autoscale_min     = 1
  autoscale_max     = 3
  autoscale_desired = 1

  target_capacity = 100

  tags = {
    "TerraformManaged" = "true"
  }
}