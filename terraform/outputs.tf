output "s3_bucket_name" {
  value       = aws_s3_bucket.django_s3.bucket
  description = "Name of the S3 bucket"
}
