locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
  region  = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com:18F/formservice-iac-modules.git//rds-postgres"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies { paths = ["../vpc"] }
dependency "vpc" { config_path = "../vpc" }



# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  ca_cert_identifier = "rds-ca-2017"
  name_prefix        = "${local.name_prefix}-agency01-microservice"

  engine            = "postgres"
  engine_version    = "10.13"
  instance_class    = "db.t2.xlarge"
  allocated_storage = 50 # in GBs

  database_name = "agency01microservice"
  db_username   = get_env("TF_VAR_db_username") # get from env variables TF_VAR_db_username
  db_password   = get_env("TF_VAR_db_password") # get from env variables TF_VAR_db_password
  db_port       = "5432"
  multi_az      = true

  database_subnet_ids             = dependency.vpc.outputs.database_subnet_ids

  # for security group
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
  mgmt_subnet_cidr_blocks = ["10.20.1.214/32"]
}