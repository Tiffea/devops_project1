#bucket for tf remote state
resource "aws_s3_bucket" "tiffea-tfstate_bucket" {
  #checkov:skip=CKV_AWS_144: no need in a replica on this scale
  #checkov:skip=CKV2_AWS_62: No event driven pipeline
  #checkov:skip=CKV_AWS_18: we have only one role that use S3 bucket.No reason.
  #checkov:skip=CKV_AWS_145: kms is not in use in this project in a favor of sse-s3
  bucket = "tf-bucket-p4523432"
  tags = {
    Name = "tiffea-tfstate_bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "devops1-tf_public_access_block" {
  bucket = aws_s3_bucket.tiffea-tfstate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_server_side_encryption_configuration" "devops1-tf_s3-bucket-cnfg" {
  bucket = aws_s3_bucket.tiffea-tfstate_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# enable versioning for this bucket
resource "aws_s3_bucket_versioning" "devops1-tf_bucket1_versioning" {
  bucket = aws_s3_bucket.tiffea-tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "devops1-tf_bucket1_lcongf" {
  bucket = aws_s3_bucket.tiffea-tfstate_bucket.id
  rule {
    id = "tf-bucket-config"

    status = "Enabled"

    filter {}

    #for only old versions
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}
##

#dynamo db

resource "aws_dynamodb_table" "devops1-dynamoDB" {
  #checkov:skip=CKV_AWS_28: no need on this scale
  #checkov:skip=CKV_AWS_119: default AWS-managed encryption is enough
  name         = "DynamoDB-for-tfstate"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" #string
  }
}
