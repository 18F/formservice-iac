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
  source = "git@github.com:18F/formservice-iac-modules.git//tgw-routes"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## DEPENDENCIES
dependencies {
  paths = ["../vpc"]
}
dependency "vpc" { config_path = "../vpc" }
dependency "mgmt-vpc" { config_path = "../../../dev2/mgmt/vpc" }


# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-hub"
  
  tgw_id      = dependency.mgmt-vpc.outputs.tgw_id
  
  vpc_id                    = dependency.vpc.outputs.vpc_id
  destination_cidr_block    = "10.0.0.0/8"
  public_subnet_ids         = dependency.vpc.outputs.public_subnet_ids

  public_route_table_ids    = dependency.vpc.outputs.public_route_table_ids
  private_route_table_ids   = dependency.vpc.outputs.private_route_table_ids
  database_route_table_ids  = dependency.vpc.outputs.database_route_table_ids
}
