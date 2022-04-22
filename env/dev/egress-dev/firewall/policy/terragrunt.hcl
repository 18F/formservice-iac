locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
}

// specifiy module source
terraform {
  source = "git::https://github.com/18F/formservice-iac-modules.git//network-fw-policy"
}

dependencies      { paths = [ "../dev/hub/firewall-rules", "../dev/mgmt/firewall-rules", "../dev/runtime/firewall-rules", "../drop-all/firewall-rules" ] }
dependency "hub"  { config_path = "../dev/hub/firewall-rules" }
dependency "runtime"  { config_path = "../dev/runtime/firewall-rules" }
dependency "mgmt"  { config_path = "../dev/mgmt/firewall-rules" }
dependency "drop"  { config_path = "../drop-all/firewall-rules" }

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  name_prefix = local.name_prefix
  policy_list = [{
                  rule_arn = "${dependency.hub.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.mgmt.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.runtime.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.drop.outputs.rule_arn}"
                  }
                ]
}
