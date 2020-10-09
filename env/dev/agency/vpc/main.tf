# ---------------------------------------------------------------------------
# Set S3 backend for persisting TF state file remotely (bucket and dynamodb table must exist)
# ---------------------------------------------------------------------------

terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-gov-west-1"
    profile = "tfuser-faas-dev"
    key     = "dev/agency/vpc/terraform.tfstate"
    bucket  = "faas-dev-terraform-state"

    # DynamoDB table name
    dynamodb_table = "faas-dev-terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------------------------------------------------------
# Agency VPC
# ---------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.57.0"

  name = "agency-vpc"
  cidr = "10.10.0.0/16"

  azs              = ["us-gov-west-1a", "us-gov-west-1b"]
  private_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets   = ["10.10.11.0/24", "10.10.12.0/24"]
  database_subnets = ["10.10.21.0/24", "10.10.22.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "AgencyVPC"
  }

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
  }
}




