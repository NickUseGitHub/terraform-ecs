module "app_vpc" {
  source = "./modules/vpc"
}

module "app_ecs" {
  source = "./modules/ecs"

  vpc_instance = module.app_vpc.vpc_instance
  vpc_public_subnet = module.app_vpc.vpc_public_subnet
  vpc_public_subnet_1 = module.app_vpc.vpc_public_subnet_1
}
