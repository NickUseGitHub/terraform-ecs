module "app_vpc" {
  source = "./modules/vpc"
}

module "app_ecs" {
  source = "./modules/ecs"

  vpc_instance = module.app_vpc.vpc_instance
}
