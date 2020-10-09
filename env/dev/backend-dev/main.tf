terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-gov-west-1"
}

module "s3_backend" {
  source = "../../../modules/s3-backend"

  region              = "us-gov-west-1"
  bucket_name         = "faasdev-terraform-state"
  dynamodb_table_name = "faasdev-terraform-state-locks"
}

output "s3_bucket_arn" {
  value       = module.s3_backend.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = module.s3_backend.dynamodb_table_name
  description = "The name of the DynamoDB table"
}