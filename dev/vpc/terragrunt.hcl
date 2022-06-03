locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.account_vars.locals.environment
  aws_region  = local.region_vars.locals.aws_region
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.14.0"
}

prevent_destroy = true

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "${local.environment}-main"
  cidr = "10.22.0.0/16"

  azs             = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  private_subnets = ["10.22.0.0/20", "10.22.16.0/20", "10.22.32.0/20"]
  public_subnets  = ["10.22.128.0/20", "10.22.144.0/20", "10.22.160.0/20"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.environment}-main-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                         = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.environment}-main-cluster" = "shared"
    "kubernetes.io/role/elb"                                  = "1"
  }
}