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
  source = "git::https://github.com/18F/formservice-iac-modules.git//s3-bucket"
}

inputs = {
  // create s3 bucket to store runtime-submission-epa docker logs
  bucket_prefix                     = "epa-docker-logs"
  // create a lifecycle configuration to delete objects after 183 days (6 months)
  lifecycle_configuration_rule_id   = "expiration"
  expiration_days                   = 183
  status                            = "Enabled"
}
