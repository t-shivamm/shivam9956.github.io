
output "userdata_script_s3_attributes" {
  value = {
    bucket = aws_s3_bucket_object.object.bucket
    key    = aws_s3_bucket_object.object.key
    md5    = aws_s3_bucket_object.object.etag
  }
}
