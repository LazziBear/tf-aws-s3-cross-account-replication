variable "source_region" {
  description = "AWS Deployment region.."
  default     = "us-east-1"
}

variable "dest_region" {
  description = "AWS Deployment region.."
  default     = "us-east-1"
}

variable "source_bucket_name" {
  description = "Your Source Bucket Name"
  default     = "source"
}

variable "dest_bucket_name" {
  description = "Your Destination Bucket Name"
  default     = "destination"
}