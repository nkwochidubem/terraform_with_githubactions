## Use this file to setup S3 Bucket and lock it using DynamoDB 
## to prevent concurrent overiding of the terraform state
## saved into the S3 Bucket

provider "aws" {
  region = "us-east-1"
}

# 1. The S3 Bucket for State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "wpterraformstatedev1234" # Must be globally unique
  
  lifecycle {
    prevent_destroy = true # Safety first!
  }
}

# 2. Enable Versioning (Crucial for recovery)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Encrypt the Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



















