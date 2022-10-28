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

dependencies      { paths = [ "../prod/hub/firewall-rules", "../prod/mgmt/firewall-rules", "../prod/runtime/firewall-rules", "../test/hub/firewall-rules", "../test/runtime/firewall-rules","../drop-all/firewall-rules" ] }
dependency "prod_hub"  { config_path = "../prod/hub/firewall-rules" }
dependency "prod_runtime"  { config_path = "../prod/runtime/firewall-rules" }
dependency "prod_mgmt"  { config_path = "../prod/mgmt/firewall-rules" }
dependency "test_hub"  { config_path = "../test/hub/firewall-rules" }
dependency "test_runtime"  { config_path = "../test/runtime/firewall-rules" }
dependency "dev_hub"  { config_path = "../dev/hub/firewall-rules" }
dependency "drop"  { config_path = "../drop-all/firewall-rules" }

// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  name_prefix = local.name_prefix
  policy_list = [{
                  rule_arn = "${dependency.prod_hub.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.prod_mgmt.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.prod_runtime.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.test_hub.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.test_runtime.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.dev_hub.outputs.rule_arn}"
                  },
                  {
                  rule_arn = "${dependency.drop.outputs.rule_arn}"
                  }
                ]
}
