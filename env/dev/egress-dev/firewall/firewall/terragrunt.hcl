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
  source = "git::https://github.com/18F/formservice-iac-modules.git//network-fw?ref=dev"
}

dependencies         { paths = [ "../policy", "../../egress-vpc"] }
dependency "policy"  { config_path = "../policy" }
dependency "vpc"     { config_path = "../../egress-vpc" }


// include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

// pass variables into module
inputs = {
  name_prefix         = local.name_prefix
  log_retention_days  = 180
  firewall_policy_arn = dependency.policy.outputs.policy_arn
  vpc_id              = dependency.vpc.outputs.vpc_id

  firewall_policy_change_protection = true
  subnet_change_protection          = true
  delete_protection                 = true

  subnet_mapping = [{
                    subnet_id = "${dependency.vpc.outputs.inspection_subnets[0]}"
                    },
                    {
                    subnet_id = "${dependency.vpc.outputs.inspection_subnets[1]}"
                    },
                    {
                    subnet_id = "${dependency.vpc.outputs.inspection_subnets[2]}"
                    }
                  ]
}
