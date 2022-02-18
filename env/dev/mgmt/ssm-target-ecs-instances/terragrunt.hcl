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
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//maintenance-window?ref=maintenance-window"
}

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// // depends on maintenance window
// dependencies {
//   paths = [ "../ssm-window-thurs-7am-et" ]
// }
// dependency "ssm-window-thurs-7am-et" {
//   config_path = "../ssm-window-thurs-7am-et"
// }

// pass variables into module
inputs = {
  account_num                 = "${local.account_num}"
  env                         = "${local.env}"
  // maintenance window target for hub-formio and runtime-submission ecs instances
  window_id     = module.ssm-window-thurs-7am-et.id
  name          = "ecs-instances"
  resource_type = "INSTANCE"
  key           = "tag:Name"
  values        = ["faas-${local.env}-runtime-submission-env","faas-${local.env}-hub-formio-env"]
}
