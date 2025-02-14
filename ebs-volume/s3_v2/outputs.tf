
output "s3Info" {
  value = {
    id                          = aws_s3_bucket.this.id
    arn                         = aws_s3_bucket.this.arn
    bucket_domain_name          = aws_s3_bucket.this.bucket_domain_name
    bucket_regional_domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    website_domain              = aws_s3_bucket.this.website_domain
    hosted_zone_id              = aws_s3_bucket.this.hosted_zone_id
  }
}
