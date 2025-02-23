resource "aws_s3_bucket" "sports-analytics-data-lake" {
  bucket = "ratnetworks-sports-analytics-data-lake"
  force_destroy = true
  tags = {
    Name        = "ratnetworks-sports-analytics-data-lake"
    Environment = "prod"
  }
}

#resource "aws_s3_bucket_public_access_block" "sports-analytics-data-lake-block" {
#  bucket = "aws_s3_bucket.sports-analytics-data-lake.bucket"
#  block_public_acls = true
#  block_public_policy = true
#  ignore_public_acls = true
#  restrict_public_buckets = true
#}
