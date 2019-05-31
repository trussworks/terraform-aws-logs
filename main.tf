/**
 * Supports two main uses cases:
 *
 * 1. Creates and configures a single private S3 bucket for storing logs from various AWS services, which are nested as bucket prefixes. Logs will expire after a default of 90 days, with option to configure retention value.
 * 1. Creates and configures a single private S3 bucket for a single AWS service. Logs will expire after a default of 90 days, with option to configure retention value.
 *
 * Logging from the following services is supported for both cases:
 *
 * * [CloudTrail](https://aws.amazon.com/cloudtrail/)
 * * [Config](https://aws.amazon.com/config/)
 * * [Classic Load Balancer (ELB) and Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/)
 * * [RedShift](https://aws.amazon.com/redshift/)
 * * [S3](https://aws.amazon.com/s3/)
 *
 * ## Usage for a single log bucket storing logs from all services
 *
 *     # Allows all services to log to bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs"
 *       region         = "us-west-2"
 *     }
 *
 * ## Usage for a single log bucket storing logs from a single service
 *
 *     #  Allows only the service specified (elb in this case) to log to the bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs-elb"
 *       region         = "us-west-2"
 *       default_allow  = false
 *       allow_s3       = true
 *       allow_elb      = true
 *     }
 *
 * ## Usage for a single log bucket storing logs from multiple specified services
 *
 *     #  Allows only the services specified (alb and elb in this case) to log to the bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs-elb"
 *       region         = "us-west-2"
 *       default_allow  = false
 *       allow_s3       = true
 *       allow_alb      = true
 *       allow_elb      = true
 *     }
 *
 * ## Usage for a private bucket with no policies
 *
 *     #  Allows no services to log to the bucket
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs-elb"
 *       region         = "us-west-2"
 *       default_allow  = false
 *     }
 */

# Get the account id of the AWS ELB service account in a given region for the
# purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {}

# Get the account id of the RedShift service account in a given region for the
# purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {}

# The AWS region currently being used.
data "aws_region" "current" {}

# The AWS account id
data "aws_caller_identity" "current" {}

#
# S3 Bucket
#

resource "aws_s3_bucket" "aws_logs" {
  bucket = "${var.s3_bucket_name}"

  acl    = "${var.default_allow || var.allow_s3 ? "log-delivery-write" : "private"}"
  region = "${var.region}"

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    expiration {
      days = "${var.s3_log_bucket_retention}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name = "${var.s3_bucket_name}"
  }
}

# allow_cloudtrail
data "aws_iam_policy_document" "cloudtrail" {
  statement {
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
    sid       = "cloudtrail-logs-get-bucket-acl"
  }

  statement {
    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.cloudtrail_logs_prefix}/*"]
    sid       = "cloudtrail-logs-put-object"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_cloudtrail" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_cloudtrail) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.cloudtrail.json}"
}

# allow_cloudwatch
data "aws_iam_policy_document" "cloudwatch" {
  statement {
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
    sid       = "cloudwatch-logs-get-bucket-acl"
  }

  statement {
    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.cloudwatch_logs_prefix}/*"]
    sid       = "cloudwatch-logs-put-object"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_cloudwatch" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_cloudwatch) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.cloudwatch.json}"
}

# allow_config
data "aws_iam_policy_document" "config" {
  statement {
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
    sid       = "config-permissions-check"
  }

  statement {
    actions = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.config_logs_prefix}/*"]
    sid       = "config-bucket-delivery"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_config" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_config) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.config.json}"
}

# allow_elb
data "aws_iam_policy_document" "elb" {
  statement {
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.elb_logs_prefix}/*"]
    sid       = "elb-logs-put-object"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_elb" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_elb) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.elb.json}"
}

# allow_alb
data "aws_iam_policy_document" "alb" {
  statement {
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.alb_logs_prefix}/*"]
    sid       = "alb-logs-put-object"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_alb" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_alb) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.alb.json}"
}

# allow_redshift
data "aws_iam_policy_document" "redshift" {
  statement {
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_redshift_service_account.main.id}:user/logs"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}/${var.redshift_logs_prefix}/*"]
    sid       = "redshift-logs-put-object"
  }

  statement {
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_redshift_service_account.main.id}:user/logs"]
    }

    resources = ["arn:aws:s3:::${var.s3_bucket_name}"]
    sid       = "redshift-logs-get-bucket-acl"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_redshift" {
  bucket = "${aws_s3_bucket.aws_logs.id}"
  count  = "${var.default_allow || (var.allow_s3 && var.allow_redshift) ? 1 : 0}"

  policy = "${data.aws_iam_policy_document.redshift.json}"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = "${aws_s3_bucket.aws_logs.id}"

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
