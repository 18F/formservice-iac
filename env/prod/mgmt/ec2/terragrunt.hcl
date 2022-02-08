locals {
  # Automatically load environment-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  account_num = local.account_vars.locals.aws_account_id
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  region      = local.region_vars.locals.aws_region
}

terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//ec2?ref=ec2"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  account_num           = "${local.account_num}"
  env                   = "${local.env}"
  project               = "${local.project}"
  region                = "${local.region}"
  purpose               = "mgmt-server-FORMS-344"
  ami                   = "ami-0382f110636a0a582"   # CIS Amazon Linux 2 Benchmark v1.0.0.29
  instance_type         = "t2.small"
  subnet_id             = "subnet-00e100a42cc46801c" # dependency.vpc.outputs.private_subnet_ids[0]
  iam_instance_profile  = "fass-prod-ssm-instance-role"
  volume_size           = 50

  // test local-exec provisioner
  local_exec            = "echo 'This is an example of a local_exec provisioner...'"

  // run post-install script after instance boots up
  remote_exec           = <<EOT

  // copy post-install script from s3 to this instance
  aws s3 cp s3://faas-prod-mgmt-bucket/mgmt-server /home/ssm-user --recursive  --region us-gov-west-1

  // update file permissions
  sudo chmod +x /home/ssm-user/mgmt-server-post-install.sh

  // execute script
  bash /home/ssm-user/mgmt-server-post-install.sh
  EOT
}
