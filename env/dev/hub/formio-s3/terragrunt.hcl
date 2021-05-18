locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
  aws_account_id = local.account_vars.locals.aws_account_id
}

# MODULE
terraform {
  source = "git@github.com:18F/formservice-iac-modules.git//formio-s3"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-hub"
  aws_account_id = local.aws_account_id
}
