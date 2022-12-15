
module "create_vpc" {
  source         = "modules/vpc"
  region         = var.region
  env_tags       = var.env_tags
  env_name       = var.env_name
  project_name   = var.project_name
  public_prefix  = var.public_prefix
  private_prefix = var.private_prefix
}

module "create_security_group" {
  source         = "modules/security"
  region         = var.region
  vpc_id         = module.create_vpc.vpc_id
  env_tags       = var.env_tags
  project_name   = var.project_name
}

module "create_ec2_public" {
  source   = "modules/ec2"

  region         = var.region
  env_tags       = var.env_tags
  env_name       = var.env_name
  project_name   = var.project_name

  security_group_id = module.create_security_group.security_group_id
  instance_type     = var.instance_type
  subnet_id         = module.create_vpc.public_subnet_id[0]
}

module "create_ec2_private" {
  source   = "modules/ec2"

  region         = var.region
  env_tags       = var.env_tags
  env_name       = var.env_name
  project_name   = var.project_name

  security_group_id = module.create_security_group.security_group_id
  instance_type     = var.instance_type
  subnet_id         = module.create_vpc.private_subnet_id[0]
}