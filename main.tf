module "s3-cross-account-replication" {
  source = "./modules/s3-cross-account-replicartion"

  source_bucket_name = var.source_bucket_name
  source_region      = var.source_region
  dest_bucket_name   = var.dest_bucket_name
  dest_region        = var.dest_region

  providers = {
    aws.source = aws.source
    aws.dest   = aws.dest
  }
}