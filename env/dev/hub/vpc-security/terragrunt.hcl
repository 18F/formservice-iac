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

## DEPENDENCIES
dependencies {
   paths = ["../vpc"]
 }
 dependency "vpc" { config_path = "../vpc" }

## MODULE
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//vpc-security?ref=dev"
}

## MAIN
inputs = {
  name_prefix = "${local.name_prefix}"
  vpc_id = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = tolist([dependency.vpc.outputs.vpc_cidr_block])
}
