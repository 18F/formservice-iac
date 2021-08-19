# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "tfuser-faas-dev"
  aws_account_id = "306851503416" # TODO: replace me with your AWS account ID!
  aws_profile    = "tfuser-faas-dev"
}