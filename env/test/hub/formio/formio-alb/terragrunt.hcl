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
  source = "git::https://github.com/18F/formservice-iac-modules.git//formio-alb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies {
  paths = ["../../vpc", "../security","../../../mgmt/alb-access-logs"]
}
dependency "vpc" { config_path = "../../vpc" }
dependency "formio-security" { config_path = "../security" }
dependency "alb-logs" { config_path = "../../../mgmt/alb-access-logs" }


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}"
  hub = true

  vpc_id  = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  
  enable_deletion_protection = false
  enable_access_logs = true
  access_logs_bucket_name = dependency.alb-logs.outputs.bucket_name

  ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn = "arn:aws-us-gov:acm:us-gov-west-1:306851503416:certificate/5bb968f2-c8a4-4a7d-b877-de181ac1481d"
  load_balancing_algo = "least_outstanding_requests"

  health_path = "/health"
  healthy_threshold = 3
  unhealthy_threshold = 3
  health_timeout = 5
  health_interval = 30
  
}
