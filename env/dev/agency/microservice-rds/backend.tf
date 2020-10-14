# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# backend for dev/agency/microservice-rds state storage
#  (bucket and dynamodb table must exist)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_version = ">=0.12.6"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-gov-west-1"
    profile = "tfuser-faas-dev"
    key     = "dev/agency/microservice-rds/terraform.tfstate"
    bucket  = "faas-dev-terraform-state"

    # DynamoDB table name
    dynamodb_table = "faas-dev-terraform-state-locks"
    encrypt        = true
  }
}

