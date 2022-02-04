# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"
}

## DEPENDENCIES - No current dependencies for this module
dependencies {
   paths = ["../../../prod/mgmt/transit-gateway", "../egress-vpc"]
 }
 dependency "transit" { config_path = "../../../prod/mgmt/transit-gateway-dev" }
 dependency "vpc" { config_path = "../egress-vpc" }

## MODULE
terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//tgw-routes"
}

## MAIN
inputs = {
  name_prefix = "${local.name_prefix}"
  transit_gateway_id = dependency.transit.outputs.transit_gateway_id
  destination_cidr_block = "10.0.0.0/8"
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  default_route_table_id = dependency.vpc.outputs.default_route_table_id
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
  inspection_route_table_ids = dependency.vpc.outputs.inspection_route_table_ids
  public_route_table_ids = []
  appliance_mode_support = "enable"
}