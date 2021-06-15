locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
}

# MODULE
terraform {
  source = "git@github.com:18F/formservice-iac-modules.git//agency-vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-hub-vpc"
  vpc_cidr = "10.30.0.0/16"
  single_nat_gateway = true # set to false for one NAT gateway per subnet
}
