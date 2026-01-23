provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}  # Values are passed via -backend-config in the workflow

}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  region = var.region
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source      = "./modules/rds"
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  subnets     = module.vpc.private_subnet_ids
  rds_sg_id   = module.security.rds_sg_id

}

module "wordpress" {
  source      = "./modules/wordpress"
  subnet_id   = module.vpc.public_subnet_id
  sg_id       = module.security.wordpress_sg_id
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  db_host     = module.rds.rds_endpoint
  key_name    = var.key_name
}
