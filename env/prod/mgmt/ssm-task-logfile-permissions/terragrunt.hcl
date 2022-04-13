locals {
  # Automatically load environment-level variables
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  account_num       = local.account_vars.locals.aws_account_id
  env               = local.environment_vars.locals.environment
}

// specifiy module source
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
dependency "ssm-target-ecs-thurs-7am-et" {
  config_path = "../ssm-target-ecs-thurs-7am-et"
}

// pass variables into module
inputs = {
  account_num                 = "${local.account_num}"
  env                         = "${local.env}"
  // maintenance window task: update ecs agent
  max_concurrency           = 1
  max_errors                = 1
  priority                  = 1
  task_arn                  = "AWS-RunShellScript"
  task_type                 = "RUN_COMMAND"
  window_id                 = dependency.ssm-window-thurs-7am-et.outputs.id
  target_type               = "WindowTargetIds"
  target_ids                = [dependency.ssm-target-ecs-thurs-7am-et.outputs.id]
  timeout_seconds           = 600
  cloudwatch_output_enabled = true
  commands                  = ["sudo find /var/log -type f -exec chmod g-wx,o-rwx {} +"]
}
