resource "aws_iam_role" "replication" {
  provider = aws.source
  name     = "${var.source_bucket_name}_replication_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  provider = aws.source
  name     = "${var.source_bucket_name}_replication_policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  provider   = aws.source
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket" "source" {
  provider      = aws.source
  bucket        = var.source_bucket_name
  force_destroy = true
}

# resource "aws_s3_bucket_acl" "source_bucket_acl" {
#   provider = aws.source

#   bucket = aws_s3_bucket.source.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "source" {
  provider = aws.source

  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled" //status = var.versioning_enable
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.source
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id = "cross-replication"
    delete_marker_replication {
      status = "Disabled"
    }
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
      #   sse_kms_encrypted_objects {
      #     status = "Enabled"
      #   }
    }
    filter {
      prefix = ""
    }

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.destination.arn
      #   storage_class = "GLACIER"
      #   encryption_configuration {
      #     replica_kms_key_id = aws_kms_key.dest-kms-key.arn
      #   }
    }
  }
}

# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle-config" {
#   provider = aws.source
#   bucket = aws_s3_bucket.source.bucket

#   rule {
#     id = var.source_lifecycle_name
#     status = "Enabled"
#     transition {
#       days          = var.transition_to_ia
#       storage_class = "STANDARD_IA"
#     }
#     transition {
#       days          = var.transition_to_glacier
#       storage_class = "GLACIER"
#     }
#   }
# }

resource "aws_s3_bucket_public_access_block" "source" {
  provider = aws.source
  bucket   = aws_s3_bucket.source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_iam_role" "destination" {
  provider = aws.dest
  name     = "${var.dest_bucket_name}_replication_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "destination" {
  provider = aws.dest
  name     = "${var.dest_bucket_name}_replication_policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.destination.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.destination.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.source.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "destination" {
  provider   = aws.dest
  role       = aws_iam_role.destination.name
  policy_arn = aws_iam_policy.destination.arn
}

resource "aws_s3_bucket" "destination" {
  provider      = aws.dest
  bucket        = var.dest_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.dest
  bucket   = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "destination" {
  provider = aws.dest
  bucket   = aws_s3_bucket.destination.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_replication_configuration" "destination" {
  provider = aws.dest
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.destination]

  role   = aws_iam_role.destination.arn
  bucket = aws_s3_bucket.destination.id

  rule {
    id = "cross-replication"
    delete_marker_replication {
      status = "Disabled"
    }
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
      #   sse_kms_encrypted_objects {
      #     status = "Enabled"
      #   }
    }
    filter {
      prefix = ""
    }

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.source.arn
      #   storage_class = "GLACIER"
      #   encryption_configuration {
      #     replica_kms_key_id = aws_kms_key.dest-kms-key.arn
      #   }
    }
  }
}
