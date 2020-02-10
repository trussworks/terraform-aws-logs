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
 * ## Terraform Versions
 *
 * Terraform 0.12. Pin module version to ~> 4.X. Submit pull-requests to master branch.
 *
 * Terraform 0.11. Pin module version to ~> 3.5.0. Submit pull-requests to terraform011 branch.
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
 *       s3_bucket_acl  = "private"
 *       region         = "us-west-2"
 *       default_allow  = false
 *     }
 *
 * ## Usage for a single log bucket storing logs from multiple accounts
 *
 *     module "aws_logs" {
 *       source         = "trussworks/logs/aws"
 *       s3_bucket_name = "my-company-aws-logs-elb"
 *       region         = "us-west-2"
 *       default_allow  = false
 *       allow_cloudtrail      = true
 *       cloudtrail_accounts = ["${data.aws_caller_identity.current.account_id}", "${aws_organizations_account.example.id}"]
 *     }
 *
 * ## Usage for a single log bucket storing logs from multiple application load balancers and network load balancers
 *
 *     module "aws_logs" {
 *       source            = "trussworks/logs/aws"
 *       s3_bucket_name    = "my-company-aws-logs-alb"
 *       region            = "us-west-2"
 *       default_allow     = false
 *       allow_alb         = true
 *       allow_nlb         = true
 *       alb_logs_prefixes = formatlist(format("alb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
 *        "alb-hello-world-prod",
 *        "alb-hello-world-staging",
 *        "alb-hello-world-experimental",
 *       ])
  *      nlb_logs_prefixes = formatlist(format("nlb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
 *        "nlb-hello-world-prod",
 *        "nlb-hello-world-staging",
 *        "nlb-hello-world-experimental",
 *       ])
 *     }
 */

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
        }
    ]
}
JSON


  vars = {
    region        = var.region
    bucket_arn    = format("arn:aws:s3:::%s", var.s3_bucket_name)
    alb_principal = data.aws_elb_service_account.main.arn
    alb_effect    = var.default_allow || var.allow_alb ? "Allow" : "Deny"
    alb_resources = jsonencode(
      formatlist(
        format("arn:aws:s3:::%s/%%s/*", var.s3_bucket_name),
        var.alb_logs_prefixes,
      ),
    )
    cloudwatch_effect = var.default_allow || var.allow_cloudwatch ? "Allow" : "Deny"
    cloudwatch_resources = jsonencode(
      format(
        "arn:aws:s3:::%s/%s/*",
        var.s3_bucket_name,
        var.cloudwatch_logs_prefix,
      ),
    )
    cloudtrail_effect = var.default_allow || var.allow_cloudtrail ? "Allow" : "Deny"
    cloudtrail_resources = length(var.cloudtrail_accounts) > 0 ? jsonencode(
      sort(
        formatlist(
          format(
            "arn:aws:s3:::%s/%s/AWSLogs/%%s/*",
            var.s3_bucket_name,
            var.cloudtrail_logs_prefix,
          ),
          var.cloudtrail_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:aws:s3:::%s/%s/AWSLogs/%s/*",
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
            "arn:aws:s3:::%s/%s/AWSLogs/%%s/Config/*",
            var.s3_bucket_name,
            var.config_logs_prefix,
          ),
          var.config_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:aws:s3:::%s/%s/AWSLogs/%s/Config/*",
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
            "arn:aws:s3:::%s/%s/AWSLogs/%%s/*",
            var.s3_bucket_name,
            var.elb_logs_prefix,
          ),
          var.elb_accounts,
        ),
      ),
      ) : jsonencode(
      format(
        "arn:aws:s3:::%s/%s/AWSLogs/%s/*",
        var.s3_bucket_name,
        var.elb_logs_prefix,
        data.aws_caller_identity.current.account_id,
      ),
    )
    nlb_effect      = var.default_allow || var.allow_nlb ? "Allow" : "Deny"
    nlb_resources = jsonencode(
      formatlist(
        format("arn:aws:s3:::%s/%%s/*", var.s3_bucket_name),
        var.nlb_logs_prefixes,
      ),
    )
    redshift_effect = var.default_allow || var.allow_redshift ? "Allow" : "Deny"
    redshift_principal = format(
      "arn:aws:iam::%s:user/logs",
      data.aws_redshift_service_account.main.id,
    )
    redshift_resources = jsonencode(
      format(
        "arn:aws:s3:::%s/%s/*",
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
