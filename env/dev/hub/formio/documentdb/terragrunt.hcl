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
  source = "git::https://github.com/18F/formservice-iac-modules.git//documentdb?ref=dev"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies      { paths = ["../../vpc", "../security"] }
dependency "vpc"  { config_path = "../../vpc" }
dependency "security" { config_path = "../security" }

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}-docdb"

  cluster_size            = 3
  master_username         = get_env("doc_db_master_username")
  master_password         = get_env("doc_db_master_password")
  instance_class          = "db.t3.medium"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = dependency.vpc.outputs.database_subnet_ids
  # allowed_security_groups = ["${dependency.security.outputs.documentdb_sg_id}"]
  allowed_cidr_blocks     = [
    "10.1.0.0/16", # mgmt vpc
    "10.12.0.0/16", # dev mgmt vpc
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[0]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[1]}",
    "${dependency.vpc.outputs.private_subnets_cidr_blocks[2]}"
  ]
  kms_key_id = dependency.security.outputs.documentdb_key_arn

}
