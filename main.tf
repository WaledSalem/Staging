provider "aws" {
    region = "eu-west-2"
    access_key = var.access_key
    secret_key = var.secret_key
}

module "vpc" {
  source      = "./vpc"

}

module "ec2" {
  source      = "./ec2"

  net_id            = module.subnets.net_id
  ami_id            = var.ami_id
  public_subnet_id  = module.subnets.public_subnet_id
  private_subnet_id = module.subnets.private_subnet_id
}

module "subnets" {
  source      = "./subnets"

  vpc_id      = module.vpc.vpc_id
}