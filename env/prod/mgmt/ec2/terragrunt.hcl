locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"
}

# MODULE
terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//mgmt-hosts"
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
  name_prefix = "${local.name_prefix}"
  
  linux_ami = "ami-088d8d0c07ace5a6d"   # CIS Amazon Linux 2 Benchmark v1.0.0.29

  linux_instance_type = "t2.small"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.private_subnet_ids[0]

  #linux_monitoring = "true"

  linux_root_block_size = "50"

  iam_instance_profile = "fass-prod-ssm-instance-role"

  user_data = <<EOF
		#! /bin/bash
		sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install git terraform
	EOF

  #kms_key = "arn:aws-us-gov:kms:us-gov-west-1:XXXXXX:key/62ffe5b2-f736-4376-acde-b9d1b6b863e0"
  #windows_tls_ingress_cidr_blocks = ["0.0.0.0/0"]
}
