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
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//formio-alb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies {
  paths = ["../../vpc", "../security"]
}
dependency "vpc" { config_path = "../../vpc" }
dependency "formio-security" { config_path = "../security" }


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}"
  hub = true

  vpc_id  = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  allowed_security_group_id = dependency.formio-security.outputs.formio_alb_sg
  
  enable_deletion_protection = false
  enable_access_logs = false
  access_logs_bucket_name = ""

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = "arn:aws-us-gov:acm:us-gov-west-1:306881650362:certificate/e0ec66c4-945f-4fba-b2dc-81aca66200b0"
  load_balancing_algo = "least_outstanding_requests"

  health_path = "/health"
  healthy_threshold = 3
  unhealthy_threshold = 3
  health_timeout = 5
  health_interval = 30
  
}
