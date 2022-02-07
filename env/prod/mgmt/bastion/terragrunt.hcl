locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"
}

terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//ec2"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  ami           = "ami-0382f110636a0a582"   # CIS Amazon Linux 2 Benchmark v1.0.0.29
  instance_type = "t2.small"
  subnet_id     = dependency.vpc.outputs.private_subnet_ids[0]
  volume_size   = 50
}