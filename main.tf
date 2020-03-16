# Get the account id of the AWS ELB service account in a given region for the
# purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {
}

# Get the account id of the RedShift service account in a given region for the
# purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {
}

# The AWS region currently being used.
data "aws_region" "current" {
}

# The AWS account id
data "aws_caller_identity" "current" {
}

# The AWS partition for differentiating between AWS commercial and GovCloud
data "aws_partition" "current" {
}

#
# S3 Bucket
#

data "template_file" "bucket_policy" {
  template = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "cloudtrail-logs-get-bucket-acl",
            "Effect": "$${cloudtrail_effect}",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "cloudtrail-logs-put-object",
            "Effect": "$${cloudtrail_effect}",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": $${cloudtrail_resources},
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "cloudwatch-logs-get-bucket-acl",
            "Effect": "$${cloudwatch_effect}",
            "Principal": {
                "Service": "logs.$${region}.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "cloudwatch-logs-put-object",
            "Effect": "$${cloudwatch_effect}",
            "Principal": {
                "Service": "logs.$${region}.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": $${cloudwatch_resources},
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "config-permissions-check",
            "Effect": "$${config_effect}",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "config-bucket-delivery",
            "Effect": "$${config_effect}",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": $${config_resources},
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "elb-logs-put-object",
            "Effect": "$${elb_effect}",
            "Principal": {
                "AWS": "$${elb_principal}"
            },
            "Action": "s3:PutObject",
            "Resource":  $${elb_resources}
        },
        {
            "Sid": "alb-logs-put-object",
            "Effect": "$${alb_effect}",
            "Principal": {
                "AWS": "$${alb_principal}"
            },
            "Action": "s3:PutObject",
            "Resource":  $${alb_resources}
        },
        {
            "Sid": "nlb-logs-put-object",
            "Effect": "$${nlb_effect}",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": $${nlb_resources},
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "nlb-logs-acl-check",
            "Effect": "$${nlb_effect}",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "redshift-logs-put-object",
            "Effect": "$${redshift_effect}",
            "Principal": {
                "AWS": "$${redshift_principal}"
            },
            "Action": "s3:PutObject",
            "Resource": $${redshift_resources}
        },
        {
            "Sid": "redshift-logs-get-bucket-acl",
            "Effect": "$${redshift_effect}",
            "Principal": {
                "AWS": "$${redshift_principal}"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "guardduty-logs-get-location",
            "Effect": "$${guardduty_effect}",
            "Principal": {
                "Service": "guardduty.amazonaws.com"
            },
            "Action": "s3:GetBucketLocation",
            "Resource": "$${bucket_arn}"
        },
        {
            "Sid": "guardduty-logs-put-object",
            "Effect": "$${guardduty_effect}",
            "Principal": {
                "Service": "guardduty.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": $${guardduty_resources}
        },
        {
            "Sid": "logs-deny-http",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "$${bucket_arn}/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
JSON


  vars = {
    region        = var.region
    bucket_arn    = format("arn:${data.aws_partition.current.partition}:s3:::%s", var.s3_bucket_name)
    alb_principal = data.aws_elb_service_account.main.arn
    alb_effect    = var.default_allow || var.allow_alb ? "Allow" : "Deny"
    alb_resources = jsonencode(
      formatlist(
        format("arn:${data.aws_partition.current.partition}:s3:::%s/%%s/*", var.s3_bucket_name),
        var.alb_logs_prefixes,
      ),
    )
    cloudwatch_effect = var.default_allow || var.allow_cloudwatch ? "Allow" : "Deny"
    cloudwatch_resources = jsonencode(
      format(
        "arn:${data.aws_partition.current.partition}:s3:::%s/%s/*",
        var.s3_bucket_name,
        var.cloudwatch_logs_prefix,
      ),
    )
    cloudtrail_effect = var.default_allow || var.allow_cloudtrail ? "Allow" : "Deny"
    cloudtrail_resources = length(var.cloudtrail_accounts) > 0 ? jsonencode(
      sort(
        formatlist(
          format(
            "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%%s/*",
            var.s3_bucket_name,
            var.cloudtrail_logs_prefix,
          ),
          var.cloudtrail_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%s/*",
        var.s3_bucket_name,
        var.cloudtrail_logs_prefix,
        data.aws_caller_identity.current.account_id,
      ),
    )
    config_effect = var.default_allow || var.allow_config ? "Allow" : "Deny"
    config_resources = length(var.config_accounts) > 0 ? jsonencode(
      sort(
        formatlist(
          format(
            "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%%s/Config/*",
            var.s3_bucket_name,
            var.config_logs_prefix,
          ),
          var.config_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%s/Config/*",
        var.s3_bucket_name,
        var.config_logs_prefix,
        data.aws_caller_identity.current.account_id,
      ),
    )
    elb_effect    = var.default_allow || var.allow_elb ? "Allow" : "Deny"
    elb_principal = data.aws_elb_service_account.main.arn
    elb_resources = length(var.elb_accounts) > 0 ? jsonencode(
      sort(
        formatlist(
          format(
            "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%%s/*",
            var.s3_bucket_name,
            var.elb_logs_prefix,
          ),
          var.elb_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:${data.aws_partition.current.partition}:s3:::%s/%s/AWSLogs/%s/*",
        var.s3_bucket_name,
        var.elb_logs_prefix,
        data.aws_caller_identity.current.account_id,
      ),
    )
    guardduty_effect = var.default_allow || var.allow_guardduty ? "Allow" : "Deny"
    guardduty_resources = jsonencode(
      formatlist(
        format("arn:%s:s3:::%s/%%s/*", data.aws_partition.current.partition, var.s3_bucket_name),
        var.guardduty_logs_prefixes,
      ),
    )
    nlb_effect = var.default_allow || var.allow_nlb ? "Allow" : "Deny"
    nlb_resources = jsonencode(
      formatlist(
        format("arn:${data.aws_partition.current.partition}:s3:::%s/%%s/*", var.s3_bucket_name),
        var.nlb_logs_prefixes,
      ),
    )
    redshift_effect = var.default_allow || var.allow_redshift ? "Allow" : "Deny"
    redshift_principal = format(
      "arn:${data.aws_partition.current.partition}:iam::%s:user/logs",
      data.aws_redshift_service_account.main.id,
    )
    redshift_resources = jsonencode(
      format(
        "arn:${data.aws_partition.current.partition}:s3:::%s/%s/*",
        var.s3_bucket_name,
        var.redshift_logs_prefix,
      ),
    )
  }
}

resource "aws_s3_bucket" "aws_logs" {
  bucket        = var.s3_bucket_name
  acl           = var.s3_bucket_acl
  region        = var.region
  policy        = data.template_file.bucket_policy.rendered
  force_destroy = var.force_destroy

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    expiration {
      days = var.s3_log_bucket_retention
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name       = var.s3_bucket_name
    Automation = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count = var.create_public_access_block ? 1 : 0

  bucket = aws_s3_bucket.aws_logs.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
