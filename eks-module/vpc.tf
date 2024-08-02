provider "aws" {
  region = var.aws_region
#  access_key = "xxxxxxxxxxxxxxx"
#  secret_key = "xxxxxxxxxxxxxxx"
}
data "aws_availability_zones" "available" {
  
}
locals {
  cluster_name = "yash-eks-${random_string.suffix.result}"
}
resource "random_string" "suffix" {
  length = 8
  special = false
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "yash-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
