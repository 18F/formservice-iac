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
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//ecr"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## DEPENDENCIES
#dependencies {
#  paths = ["../vpc"]
#}
#dependency "vpc" { config_path = "../vpc" }


# MAIN
inputs = {
 ## no inputs for now
}
