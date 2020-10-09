# ---------------------------------------------------------------------------
# Create an s3 bucket and DynamoDB table for Terraform remote backend
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  acl    = "private"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Env = "Dev"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}