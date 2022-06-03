locals {
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  default_custom = { "Custom Tags" = "False" }
  account_id     = local.account_vars.locals.aws_account_id
  environment    = local.account_vars.locals.environment
  aws_region     = local.region_vars.locals.aws_region
  name          = "terraform-testenv"
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terraform-tfstates-examples"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region_vars.locals.aws_region
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
    allowed_account_ids = ["${local.account_id}"]
    region              = "${local.aws_region}"
    access_key = data.vault_aws_access_credentials.creds.access_key
    secret_key = data.vault_aws_access_credentials.creds.secret_key
    token      = data.vault_aws_access_credentials.creds.security_token
  }
  EOF
}

terraform_version_constraint  = ">= 0.15"
terragrunt_version_constraint = ">= 0.29"