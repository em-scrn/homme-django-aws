output "s3_bucket_name" {
  value       = aws_s3_bucket.django_s3.bucket
  description = "Name of the S3 bucket"
}

output "ecr_url" {
  value = aws_ecr_repository.django_aws_repo.repository_url
  description = "Full URL of the ECR"
}