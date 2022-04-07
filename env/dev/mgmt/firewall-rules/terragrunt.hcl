locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  account_num = local.account_vars.locals.aws_account_id
}

// specifiy module source
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//network-fw-rules"
}

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  rule_name = "${local.env}-allowed-domains"
  rule_type = "ALLOWLIST"
  home_networks = ["10.0.0.0/8"]
  filtered_domains = [ ".example.com", ".form.io" ]
}
