variable "region" {
  type = string
  description = "select aws region"
  default     = "us-gov-west-1"
}

variable "bucket_name" {
  type = string
  description = "s3 bucket name"
}

variable "dynamodb_table_name" {
  type = string
}