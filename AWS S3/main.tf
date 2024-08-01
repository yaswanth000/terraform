resource "aws_s3_bucket" "samplebucket" {
  bucket = "my-yashterraforms3-bucket"
}
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.samplebucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
#creating bucket ACL Private
# resource "aws_s3_bucket_acl" "example"{
#   depends_on = [ aws_s3_bucket_ownership_controls.sample ]
#   bucket = aws_s3_bucket.samplebucket.id
#   acl = "private"
# }

#creating bucket ACL Public
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.samplebucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.samplebucket.id
  acl    = "public-read"
}
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}
resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.samplebucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.samplebucket.id
  versioning_configuration {
    status = "Enabled"
  }
}