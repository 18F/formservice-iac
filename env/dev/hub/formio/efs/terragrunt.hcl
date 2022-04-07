locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  product     = local.environment_vars.locals.product
  name_prefix = "${local.project}-${local.env}-${local.subenv}-${local.product}"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//efs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies      { paths = ["../../vpc"] }
dependency "vpc"  { config_path = "../../vpc" }


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix        = "${local.name_prefix}"
  creation_token     = "${local.name_prefix}"
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  kms_key_id         = "" 
  allowed_security_groups = ["sg-002096ab9c07fb5b4"]
  #dependency.security.outputs.documentdb_key_arn


}
