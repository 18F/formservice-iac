locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  product     = local.environment_vars.locals.product
  name_prefix = "${local.project}-${local.env}-${local.subenv}-${local.product}"
  region  = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com:18F/formservice-iac-modules.git//elastic-beanstalk"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies {
  paths = ["../../vpc", "../s3", "../documentdb", "../../../mgmt/security", "../../../mgmt/formio-code-bucket"]
}
dependency "vpc" { config_path = "../../vpc" }
dependency "s3" { config_path = "../s3" }
dependency "documentdb" { config_path = "../documentdb" }
dependency "acct-security" { config_path = "../../../mgmt/security"}
dependency "code-bucket" { config_path = "../../../mgmt/formio-code-bucket"}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}"

  vpc_id  = dependency.vpc.outputs.vpc_id
  loadbalancer_subnets = dependency.vpc.outputs.public_subnet_ids
  application_subnets = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups = dependency.vpc.outputs.default_security_group_id
  code_bucket      = dependency.code-bucket.outputs.s3_bucket_name
  code_version     = "formio-hub/multicontainer-gov-7-1-6.zip"

  ssl_cert = "arn:aws-us-gov:acm:us-gov-west-1:306811362825:certificate/78cc35fb-1c63-45fb-991a-3bc92d14b6fe"

  beanstalk_ec2_role = dependency.acct-security.outputs.beanstalk_ec2_role_arn

  instance_type = "t3.medium"
  autoscale_min = 3
  autoscale_max = 5
  key_name = dependency.acct-security.outputs.prod_ec2_key_name

  MONGO          = "mongodb://${dependency.documentdb.outputs.master_username}:3Gw2F2Wlqp4579NZ@${dependency.documentdb.outputs.endpoint}:27017/formio?ssl=true"
  
  PORTAL_ENABLED = "true"
  VPAT           = "true"

  PROXY           = "true"
  DEFAULT_DATABASE  = "formio-proxy5b"
  PER_PROJECT_DBS = "true"
  PORT            = "3000"
  PRIMARY         = "true"

  FORMIO_S3_BUCKET = dependency.s3.outputs.s3_bucket_name  # s3 bucket name
  FORMIO_S3_REGION = local.region
  FORMIO_S3_KEY    = dependency.s3.outputs.s3_user_key     # pdf user access key
  FORMIO_S3_SECRET = dependency.s3.outputs.s3_user_secret  # pdf user secret key


  ADMIN_EMAIL = get_env("FORMIO_ADMIN_EMAIL")
  ADMIN_PASS  = get_env("FORMIO_ADMIN_PASS")
  DB_SECRET   = get_env("FORMIO_DB_SECRET")
  JWT_SECRET  = get_env("FORMIO_JWT_SECRET")

  LICENSE_KEY    = get_env("FORMIO_LICENSE_KEY")
  
}
