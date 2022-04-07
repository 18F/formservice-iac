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

  #set VPC CIDR
  CIDR = "10.12.0.0/16"
}

## DEPENDENCIES
dependencies {
   paths = ["../../../prod/mgmt/transit-gateway-dev" ]
 }
 dependency "transit" { config_path = "../../../prod/mgmt/transit-gateway-dev" }

## MODULE
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//mgmt-vpc?ref=ec2"
}

## MAIN
inputs = {
  name_prefix = "${local.name_prefix}-vpc"
  vpc_cidr = local.CIDR
  single_nat_gateway = true # set to false for one NAT gateway per subnet
  transit_gateway_id = dependency.transit.outputs.transit_gateway_id
  environment = local.env
}
