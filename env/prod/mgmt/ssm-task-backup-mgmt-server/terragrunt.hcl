locals {
  # Automatically load environment-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  account_num       = local.account_vars.locals.aws_account_id
  env               = local.environment_vars.locals.environment
}

// specify module source
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//ssm-task"
}

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// depends on maintenance window
dependency "ssm-window-thurs-7am-et" {
  config_path = "../ssm-window-thurs-7am-et"
}

// depends on maintenance window target
dependency "ssm-target-mgmt-server" {
  config_path = "../ssm-target-mgmt-server"
}

// pass variables into module
inputs = {
  account_num                 = "${local.account_num}"
  env                         = "${local.env}"
  // maintenance window task: backup mgmt server
  max_concurrency           = 1
  max_errors                = 1
  priority                  = 1
  task_arn                  = "AWS-RunShellScript"
  task_type                 = "RUN_COMMAND"
  window_id                 = dependency.ssm-window-thurs-7am-et.outputs.id
  target_type               = "WindowTargetIds"
  target_ids                = [dependency.ssm-target-mgmt-server.outputs.id]
  timeout_seconds           = 600
  cloudwatch_output_enabled = true
  parameters                = {
    commands               = [
      "aws s3 cp /home/ssm-user/.aws s3://faas-prod-mgmt-bucket/mgmt-server/.aws/ --recursive --region us-gov-west-1",
      "aws s3 cp /home/ssm-user/.ssh s3://faas-prod-mgmt-bucket/mgmt-server/.ssh/ --recursive --region us-gov-west-1",
      "aws s3 cp /home/ssm-user/certs s3://faas-prod-mgmt-bucket/mgmt-server/certs/ --recursive --region us-gov-west-1",
      "aws s3 cp /home/ssm-user/documentDB s3://faas-prod-mgmt-bucket/mgmt-server/documentDB/ --recursive --region us-gov-west-1",
      "aws s3 cp /home/ssm-user/packer s3://faas-prod-mgmt-bucket/mgmt-server/packer/ --recursive --region us-gov-west-1",
      "aws s3 cp /home/ssm-user/terraform s3://faas-prod-mgmt-bucket/mgmt-server/terraform/ --recursive --region us-gov-west-1"
    ]
  }
}
