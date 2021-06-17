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
  source = "git@github.com:18F/formservice-iac-modules.git//ec2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## DEPENDENCIES
dependencies {
  paths = ["../vpc"]
}
dependency "vpc" { config_path = "../vpc" }


# MAIN
inputs = {
  name_prefix = "${local.name_prefix}-mgmt"
  
  linux_ami = "ami-XXXX"   # CIS Amazon Linux 2 Benchmark - Level 1
#  windows_ami = "ami-XXX" # CIS Microsoft Windows Server 2016 Benchmark - Level 1"

  linux_instance_type = "t3.medium"
#  windows_instance_type = "t3a.large"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnet_ids[0]

  linux_monitoring = "true"
#  windows_monitoring = "false"

  linux_root_block_size = "100"
#  windows_root_block_size = "500"

  kms_key = "arn:aws-us-gov:kms:us-gov-west-1:XXXXXX:key/62ffe5b2-f736-4376-acde-b9d1b6b863e0"
  #windows_tls_ingress_cidr_blocks = ["0.0.0.0/0"]
}
