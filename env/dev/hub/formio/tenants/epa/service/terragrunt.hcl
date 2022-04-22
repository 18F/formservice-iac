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
  source = "git::https://github.com/18F/formservice-iac-modules.git//formio-enterprise-ecs"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies      { paths = ["../../ecs-cluster", "../../efs", "../../formio-alb", "../../../vpc"] }
dependency "vpc"  { config_path = "../../../vpc" }
dependency "alb"  { config_path = "../../formio-alb" }
dependency "ecs"  { config_path = "../../ecs-cluster" }
dependency "efs"  { config_path = "../../efs" }

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix            = "${local.name_prefix}"
  task_secrets           = "faas-dev-hub-formio-enterprise-secrets"
  aws_region             = "us-gov-west-1"
  log_stream_prefix      = "enterprise"
  
  enterprise_task_cpu         = 1024
  enterprise_task_memory      = 2048
  enterprise_image            = "306811362825.dkr.ecr.us-gov-west-1.amazonaws.com/formio/enterprise:7.3.1"
  enterpise_ephemeral_storage = 25

  container_mount_path        = "/src/certs"
  enterprise_volume_name      = "enterprise-storage"
  efs_file_system_id          = dependency.efs.outputs.fs_id
  efs_access_point_id         = dependency.efs.outputs.fsap_id

  vpc_id                      = dependency.vpc.outputs.vpc_id
  load_balancing_algo         = "least_outstanding_requests"
  health_path                 = "/health"
  healthy_threshold           = 3
  unhealth_threshold          = 3
  health_timeout              = 5
  health_interval             = 30
  formio_alb_listener_arn     = dependency.alb.outputs.faas_formio_alb_listener
  customer_url                = "epa.formsservice-dev.forms.gov"

  #dependency.security.outputs.documentdb_key_arn


}
