module ecs {
  source = "../modules/ecs"

  ecs_cluster_name = "ecs-demo-terraform"

  image_id          = "ami-04c0ac9468f496b8e"
  instance_type     = "t3.micro"
  instance_profile  = aws_iam_instance_profile.ecs.name
  key_name          = module.vpc.key_name

  subnet_ids    = module.vpc.private_subnet_ids
  autoscale_sg  = [module.vpc.ssh_sg_id]
  
  autoscale_min     = 1
  autoscale_max     = 10
  autoscale_desired = 2
}