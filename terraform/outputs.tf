output "product_template_storage_bucket_name" {
  description = "The name of the S3 bucket used for template storage"
  value       = aws_s3_bucket.product_template_storage.bucket
}
