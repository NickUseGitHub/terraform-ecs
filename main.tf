module "app_vpc" {
  source = "./modules/vpc"
}

module "app_ecs" {
  source = "./modules/ecs"
}
