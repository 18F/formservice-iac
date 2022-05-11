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
dependency "ssm-target-runtime-submission-epa-hourly" {
  config_path = "../ssm-target-runtime-submission-epa-hourly"
}

// pass variables into module
inputs = {
  name                      = "backup-docker-logs"
  description               = "A maintenance window task that backs up runtime-submission-epa docker logs to s3; FORMS-820"
  account_num               = "${local.account_num}"
  env                       = "${local.env}"
  max_concurrency           = 1
  max_errors                = 1
  priority                  = 1
  task_arn                  = "AWS-RunShellScript"
  task_type                 = "RUN_COMMAND"
  window_id                 = dependency.ssm-window-hourly.outputs.id
  target_type               = "WindowTargetIds"
  target_ids                = [dependency.ssm-target-runtime-submission-epa-hourly.outputs.id]
  timeout_seconds           = 600
  cloudwatch_output_enabled = true
  parameters                = {
    commands                = [<<EOT

echo 'Hello world!'

EOT
    ]
  }
}

terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//s3-bucket"

  inputs {
    // create s3 bucket to store runtime-submission-epa docker logs
    var.bucket_prefix                     = "epa-docker-logs"
    // create a lifecycle configuration to delete objects after 183 days (6 months)
    var.lifecycle_configuration_rule_id   = "expiration"
    var.expiration_days                   = 183
  }
}
