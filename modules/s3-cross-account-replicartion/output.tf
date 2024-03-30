output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}

output "dest_bucket_arn" {
  value = aws_s3_bucket.destination.arn
}