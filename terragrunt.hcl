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
  # source = "git@github.com:18F/formservice-iac-modules.git//apigw"
  source = "/Users/iMichael/Git/formservice-iac-modules/cloudtrail"
  
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## DEPENDENCIES
# dependencies {
#   paths = ["../vpc", "../../mgmt/vpc"]
# }
# dependency "vpc" { config_path = "../vpc" }
# dependency "mgmt-vpc" { config_path = "../../mgmt/vpc" }


# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-cloudtrail"
  
}
