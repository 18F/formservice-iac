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
dependency "ssm-window-hourly" {
  config_path = "../ssm-window-hourly"
}

// depends on maintenance window target
dependency "ssm-target-mgmt-server-hourly" {
  config_path = "../ssm-target-mgmt-server-hourly"
}

// pass variables into module
inputs = {
  name                      = "backup-mgmt-server"
  description               = "A maintenance window task that backs up faas-prod-mgmt-server files to s3; FORMS-531"
  account_num               = "${local.account_num}"
  env                       = "${local.env}"
  max_concurrency           = 1
  max_errors                = 1
  priority                  = 1
  task_arn                  = "AWS-RunShellScript"
  task_type                 = "RUN_COMMAND"
  window_id                 = dependency.ssm-window-hourly.outputs.id
  target_type               = "WindowTargetIds"
  target_ids                = [dependency.ssm-target-mgmt-server-hourly.outputs.id]
  timeout_seconds           = 600
  cloudwatch_output_enabled = true
  parameters                = {
    commands               = [
      "aws s3 sync /home/ssm-user/.aws s3://faas-prod-mgmt-bucket/mgmt-server/.aws/ --region us-gov-west-1",
      "aws s3 sync /home/ssm-user/.ssh s3://faas-prod-mgmt-bucket/mgmt-server/.ssh/ --region us-gov-west-1",
      "aws s3 sync /home/ssm-user/certs s3://faas-prod-mgmt-bucket/mgmt-server/certs/ --region us-gov-west-1",
      "aws s3 sync /home/ssm-user/documentDB s3://faas-prod-mgmt-bucket/mgmt-server/documentDB/ --region us-gov-west-1"
    ]
  }
}
