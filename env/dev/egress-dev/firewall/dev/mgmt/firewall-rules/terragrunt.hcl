locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"
}

// specifiy module source
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//network-fw-rules?ref=dev"
}

dependencies      { paths = [ "../../../../../mgmt/vpc" ] }
dependency "vpc"  { config_path = "../../../../../mgmt/vpc" }
// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  rule_name = "${local.name_prefix}-allowed-domains"
  rule_type = "ALLOWLIST"
  capacity = 100
  home_networks = ["${dependency.vpc.outputs.vpc_cidr_block}"]
  filtered_domains = [ ".amazonaws.com", ".githubusercontent.com",".twistlock.com", ".github.com", ".releases.hashicorp.com", ".repo.mongodb.org", ".registry.terraform.io", "amazon-ssm-packages-us-gov-west-1.s3.us-gov-east-1.amazonaws.com"]
}
