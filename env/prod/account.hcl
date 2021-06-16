# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "tts-faas-prod"
  aws_account_id = "306811362825" # TODO: replace me with your AWS account ID!
  aws_profile    = "tfuser-faas-prod"
}
