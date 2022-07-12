locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  product     = local.environment_vars.locals.product
  name_prefix = "${local.project}-${local.env}-${local.subenv}-${local.product}"
  account_num = local.account_vars.locals.aws_account_id
  region      = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//formio-security?ref=test"
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
  name_prefix = "${local.name_prefix}"

  vpc_id = dependency.vpc.outputs.vpc_id

  account_num = "${local.account_num}"
  region = "${local.region}"

  documentdb_allowed_cidr_blocks     = [
    "10.1.0.0/16", # mgmt vpc
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[0]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[1]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[2]}"
  ]

}
