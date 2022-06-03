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
  source = "git::https://github.com/18F/formservice-iac-modules.git//elastic-beanstalk-sub"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies {
  paths = ["../../vpc", "../s3", "../documentdb", "../../../mgmt/security", "../elasticbeanstalk-app"]
}
dependency "vpc" { config_path = "../../vpc" }
dependency "s3" { config_path = "../s3" }
dependency "documentdb" { config_path = "../documentdb" }
dependency "acct-security" { config_path = "../../../mgmt/security" }
dependency "ebapp" { config_path = "../elasticbeanstalk-app" }


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}"

  vpc_id  = dependency.vpc.outputs.vpc_id
  loadbalancer_subnets = dependency.vpc.outputs.public_subnet_ids
  application_subnets = dependency.vpc.outputs.private_subnet_ids
  allowed_security_groups = dependency.vpc.outputs.default_security_group_id
  app_name = dependency.ebapp.outputs.app_name
  version_name = "faas-dev-runtime-submission-app-v9.0.33-nginx:1.22.0-alpine-nonroot-user"

  ssl_cert = "arn:aws-us-gov:acm:us-gov-west-1:306881650362:certificate/dfe30a62-2de3-427c-9f9d-f00d04cbc666"

  beanstalk_ec2_role = dependency.acct-security.outputs.beanstalk_ec2_role_arn

  instance_type = "t3.medium"
  autoscale_min = 3
  autoscale_max = 5

  asg_breach_duration = 1
  asg_lower_breach_scale_increment = -1
  asg_lower_breach_threshold = 5
  asg_scaling_measure_name = "RequestCount"
  asg_scaling_period = 1
  asg_scaling_statistic = "Average"
  asg_scaling_unit = "Count/Second"
  asg_upper_breach_scale_increment = 1
  asg_upper_breach_threshold = 25
  DisableIMDSv1 = "true"
  ami_id = "ami-04372bb35fbf4e9d3"


  key_name = dependency.acct-security.outputs.ec2_key_name

  DB_SECRET          = get_env("DB_SECRET_SUB")
  JWT_SECRET         = get_env("JWT_SECRET")
  LICENSE_KEY        = get_env("LICENSE_KEY")
  MONGO              = "mongodb://${dependency.documentdb.outputs.master_username}:${get_env("doc_db_master_password")}@${dependency.documentdb.outputs.endpoint}:27017/formio?ssl=true"
  PORTAL_BASE_URL    = "https://portal-dev.forms.gov"
  PORTAL_ADMIN_KEY   = get_env("ADMIN_KEY")
  REMOTE_SECRET      = get_env("REMOTE_SECRET")
  REMOTE_PROJECT_ID  = get_env("REMOTE_PROJECT_ID")
  REMOTE_PROJECT_KEY = get_env("REMOTE_PROJECT_KEY")
}
