terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  environment_name    = var.environment_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  environment_name    = var.environment_name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  web_server_sg_id   = module.web.web_server_sg_id
  db_instance_class  = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

# EFS Storage
module "efs" {
  source = "./modules/efs"

  environment_name    = var.environment_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  web_server_sg_id   = module.web.web_server_sg_id
}

# Web Servers and Load Balancer
module "web" {
  source = "./modules/web"

  environment_name    = var.environment_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  efs_id             = module.efs.efs_id
}
