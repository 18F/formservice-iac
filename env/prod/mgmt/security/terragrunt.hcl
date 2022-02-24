locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  subenv      = local.environment_vars.locals.subenv
  name_prefix = "${local.project}-${local.env}-${local.subenv}"
  account_num = local.account_vars.locals.aws_account_id
  region      = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com-gsa:18F/formservice-iac-modules.git//acct-mgmt-security"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies      { paths = ["../vpc"] }
dependency "vpc"  { config_path = "../vpc" }

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}"

  account_num = "${local.account_num}"
  region = "${local.region}"

  prod-key-pub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJGr0FOZ8LLgGwec8H9vS9OI2NuvXoQfjslMT/he+PHT0Kxo8fWt1CRF1u1iZ9+Vak8ql/naJHBksTVErBXIbYGltmqNNY97jxvRCJiQGB5wzWTA4eGaile7JV0WyuFySQi6MpGgfsvEQOMs4TwgzdDBXJKk0IKaLbwxIzR2Vv4s4DUN1ETO8Vz1dM1Ifak0J6qYqkJ7+HEWWMKtKRGirEIwa7UvvmcTXq+PJiBe9rS05oG8YbkFHLIE04nNy99E1fnwX0/NN6MuxAwOtZc5/qQH+tvWBeQGLxArsP9kKktbzRtX/bWEsxSQFCuCkNBqFO8OJ1UrZiUNqk876GkI2Dp45iM6ws66cAM6NEbCj7KNC3zfboJenxkCBV0LE5BYFM2hWgMUsQfRMYC8nnSA/0X+IUf5Py/4BmB8Vb9tG4wPNwRfWvPgSuVbawec0ZCk9QX1lB8yFTi0auvn7OIKzE2cNrUEnIOXafyFqUBraVEnHVxrRzkXunWdW7hUFE5GUcbuvpYqCTGAaiXPJTOtpaZml2Wr9kmTPbF5DhztYwxWKcX1AqdoDDdAA3mU9+4vbsTi3q8o78f4y5qji35yTdt2EcZTjo/qWsS3C9ASdiz167KuLTUdU/tFXPRtopufsHZxHHipoQpCLadrQr3+rLY5u4pVyGl1UtyClsWtFUnw== AWS Forms.gov Key"

}
