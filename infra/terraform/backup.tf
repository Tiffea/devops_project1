
#create a bucket
resource "aws_s3_bucket" "devops1_bucket1" {
    #checkov:skip=CKV_AWS_144: no need in a replica on this scale
    #checkov:skip=CKV2_AWS_62: No event driven pipeline
    #checkov:skip=CKV_AWS_18: we have only one role that use S3 bucket.No reason.
    #checkov:skip=CKV_AWS_145: kms is not in use in this project in a favor of sse-s3
    bucket = "bucket-tiffea5656"
    tags = {
        Name = "Main_devops1_Bucket"
    }
}
#make a bucket more secure - restrict potential danger
resource "aws_s3_bucket_public_access_block" "devops1_public_access_block" {
  bucket = aws_s3_bucket.devops1_bucket1.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets  = true

}

#configure encription
resource "aws_s3_bucket_server_side_encryption_configuration" "devops1-s3-bucket-cnfg" {
  bucket = aws_s3_bucket.devops1_bucket1.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "devops1_bucket1_versioning" {
  bucket = aws_s3_bucket.devops1_bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "devops1_bucket1_lcongf" {
    bucket = aws_s3_bucket.devops1_bucket1.id
    rule {
        id = "old-backups"
        
        status = "Enabled"
    
        filter {}

        expiration {
            days = 30
        }
        noncurrent_version_expiration {
            noncurrent_days = 30
        }

        abort_incomplete_multipart_upload {
          days_after_initiation = 3
        }
    }
}
