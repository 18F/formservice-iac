locals {
  # Automatically load environment-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  account_num = local.account_vars.locals.aws_account_id
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.aws_region
  name_prefix = "${local.project}"
}

terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//sns-topic"
}

inputs = {
  name_prefix      = "${local.name_prefix}-alerts"
  account_num      = "${local.account_num}"
  region           = "${local.region}"
  display_name     = "FormsServiceAlerts"
  dev_account_num  = get_env("dev_account_number")
  test_account_num = get_env("test_account_number")
}

