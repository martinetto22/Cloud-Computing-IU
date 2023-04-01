output "s3-buckets" {
  description = "Buckets created"
  value = aws_s3_bucket.my-bucket.bucket
}