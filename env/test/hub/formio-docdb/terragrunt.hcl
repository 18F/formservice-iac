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
  source = "git@github.com:18F/formservice-iac-modules.git//documentdb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# DEPENDENCIES
dependencies      { paths = ["../vpc"] }
dependency "vpc"  { config_path = "../vpc" }

# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-hub-docdb"

  cluster_size            = 3
  master_username         = get_env("TF_VAR_master_username")
  master_password         = get_env("TF_VAR_master_password")
  instance_class          = "db.r5.large"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = dependency.vpc.outputs.database_subnet_ids
  allowed_security_groups = [dependency.vpc.outputs.default_security_group_id]
  allowed_cidr_blocks     = [
    "10.20.1.214/32", # bastion
    "10.1.0.0/16", # mgmt vpc
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[0]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[1]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[2]}"
  ]

}
