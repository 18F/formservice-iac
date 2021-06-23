# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"

}

# DEPENDENCIES
dependencies {
   paths = ["../vpc"]
}

dependency "vpc" { config_path = "../vpc" }

## MODULE
terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints"
}

## MAIN
inputs = {
  
  vpc_id             = dependency.vpc.vpc_id
  #security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      tags                = { Name = "${local.name_prefix}-s3-vpc-endpoint" }
    },
    sns = {
      service             = "sns"
      subnet_ids          = dependency.vpc.private_subnets
      tags                = { Name = "${local.name_prefix}-sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      # security_group_ids  = ["sg-987654321"]
      subnet_ids          = dependency.vpc.private_subnets
      tags                = { Name = "${local.name_prefix}-sqs-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = dependency.vpc.private_subnets
      tags                = { Name = "${local.name_prefix}-ssm-vpc-endpoint" }

    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = true
      subnet_ids          = dependency.vpc.private_subnets
      tags                = { Name = "${local.name_prefix}-lambda-vpc-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = dependency.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${local.name_prefix}-ecr-api-vpc-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = dependency.vpc.private_subnets
      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${local.name_prefix}-ecr-dkr-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
      subnet_ids          = dependency.vpc.private_subnets
      tags                = { Name = "${local.name_prefix}-kms-vpc-endpoint" }
    }
  }

  tags = {
    Owner       = "faas-prod"
    Environment = "PROD"
  }
}

}