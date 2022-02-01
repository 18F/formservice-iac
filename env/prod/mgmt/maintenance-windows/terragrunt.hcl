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
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//maintenance-windows"
}

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  account_num                 = "${local.account_num}"
  env                         = "${local.env}"
  // maintenance window to run every Thursday 7am-9am ET
  maintenance_window_name     = "thursdays-7am-et"
  maintenance_window_schedule = "cron(0 0 7 ? * THU *)"
  maintenance_window_duration = "2"
  maintenance_window_cutoff   = "1"
}