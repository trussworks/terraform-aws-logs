# Get the account id of the AWS ALB and ELB service account in a given region for the
# purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {
}

# Get the account id of the RedShift service account in a given region for the
# purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {
}

# The AWS account id
data "aws_caller_identity" "current" {
}

# The current cregion
data "aws_region" "current" {
}

# The AWS partition for differentiating between AWS commercial and GovCloud
data "aws_partition" "current" {
}

locals {
  # S3 bucket ARN
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"

  #
  # CloudTrail locals
  #

  # supports logging to multiple accounts
  # doesn't support to multiple prefixes

  # allow cloudtrail policies if default_allow or allow_cloudtrail are true
  cloudtrail_effect = var.default_allow || var.allow_cloudtrail ? "Allow" : "Deny"

  # use the cloudtrail_accounts to grant access if provided, otherwise grant access to the current account id
  cloudtrail_accounts = length(var.cloudtrail_accounts) > 0 ? var.cloudtrail_accounts : [data.aws_caller_identity.current.account_id]

  # if var.cloudtrail_logs_prefix is empty then be sure to remove // in the path
  cloudtrail_logs_path = var.cloudtrail_logs_prefix == "" ? "AWSLogs" : "${var.cloudtrail_logs_prefix}/AWSLogs"

  # finally, format the full final resources ARN list
  cloudtrail_resources = toset(formatlist("${local.bucket_arn}/${local.cloudtrail_logs_path}/%s/*", local.cloudtrail_accounts))

  #
  # Cloudwatch Logs locals
  #

  # doesn't support logging to multiple accounts
  # doesn't support logging to mulitple prefixes
  cloudwatch_effect = var.default_allow || var.allow_cloudwatch ? "Allow" : "Deny"

  # region specific logs service principal
  cloudwatch_service = format(
    "logs.%s.amazonaws.com", data.aws_region.current.name
  )

  cloudwatch_resource = "${local.bucket_arn}/${var.cloudwatch_logs_prefix}/*"

  #
  # Config locals
  #

  # supports logging to muliple accounts
  # doesn't support logging to muliple prefixes
  config_effect = var.default_allow || var.allow_config ? "Allow" : "Deny"

  config_accounts = length(var.config_accounts) > 0 ? var.config_accounts : [data.aws_caller_identity.current.account_id]

  config_logs_path = var.config_logs_prefix == "" ? "AWSLogs" : "${var.config_logs_prefix}/AWSLogs"

  config_resources = sort(formatlist("${local.bucket_arn}/${local.config_logs_path}/%s/Config/*", local.config_accounts))

  #
  # ELB locals
  #

  # supports logging to muliple accounts
  # doesn't support logging to multiple prefixes
  elb_effect = var.default_allow || var.allow_elb ? "Allow" : "Deny"

  elb_accounts = length(var.elb_accounts) > 0 ? var.elb_accounts : [data.aws_caller_identity.current.account_id]

  elb_logs_path = var.elb_logs_prefix == "" ? "AWSLogs" : "${var.elb_logs_prefix}/AWSLogs"

  elb_resources = sort(formatlist("${local.bucket_arn}/${local.elb_logs_path}/%s/*", local.elb_accounts))

  #
  # ALB locals
  #

  # doesn't support logging to multiple accounts
  alb_account = var.alb_account != "" ? var.alb_account : data.aws_caller_identity.current.account_id

  # supports logging to multiple prefixes
  alb_effect = var.default_allow || var.allow_alb ? "Allow" : "Deny"

  # if the list of prefixes contains "", set an append_root_prefix flag
  alb_include_root_prefix = contains(var.alb_logs_prefixes, "") ? true : false

  # create a list of paths, but remove any prefixes containing "" using compact
  alb_logs_path_temp = formatlist("%s/AWSLogs", compact(var.alb_logs_prefixes))

  # now append an "AWSLogs" path to the list if alb_include_root_prefix is true
  alb_logs_path = local.alb_include_root_prefix ? concat(local.alb_logs_path_temp, ["AWSLogs"]) : local.alb_logs_path_temp

  # finally, format the full final resources ARN list
  alb_resources = sort(formatlist("${local.bucket_arn}/%s/${local.alb_account}/*", local.alb_logs_path))

  #
  # NLB locals
  #

  # doesn't support logging to multiple accounts
  nlb_account = var.nlb_account != "" ? var.nlb_account : data.aws_caller_identity.current.account_id

  # supports logging to multiple prefixes
  nlb_effect = var.default_allow || var.allow_nlb ? "Allow" : "Deny"

  nlb_include_root_prefix = contains(var.nlb_logs_prefixes, "") ? true : false

  nlb_logs_path_temp = formatlist("%s/AWSLogs", compact(var.nlb_logs_prefixes))

  nlb_logs_path = local.nlb_include_root_prefix ? concat(local.nlb_logs_path_temp, ["AWSLogs"]) : local.nlb_logs_path_temp

  nlb_resources = sort(formatlist("${local.bucket_arn}/%s/${local.nlb_account}/*", local.nlb_logs_path))

  #
  # Redshift locals
  #

  # doesn't support logging to multiple accounts
  # doesn't support logging to multiple prefixes
  redshift_effect = var.default_allow || var.allow_redshift ? "Allow" : "Deny"

  # redshift logs user in our region
  redshift_principal = "arn:${data.aws_partition.current.partition}:iam::${data.aws_redshift_service_account.main.id}:user/logs"

  redshift_resource = "${local.bucket_arn}/${var.redshift_logs_prefix}/*"
}

#
# S3 Bucket
#

data "aws_iam_policy_document" "main" {

  #
  # CloudTrail bucket policies
  #

  statement {
    sid    = "cloudtrail-logs-get-bucket-acl"
    effect = local.cloudtrail_effect
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "cloudtrail-logs-put-object"
    effect = local.cloudtrail_effect
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = local.cloudtrail_resources
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  #
  # CloudWatch bucket policies
  #

  statement {
    sid    = "cloudwatch-logs-get-bucket-acl"
    effect = local.cloudwatch_effect
    principals {
      type        = "Service"
      identifiers = [local.cloudwatch_service]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "cloudwatch-logs-put-object"
    effect = local.cloudwatch_effect
    principals {
      type        = "Service"
      identifiers = [local.cloudwatch_service]
    }
    actions = ["s3:PutObject"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    resources = [local.cloudwatch_resource]
  }

  #
  # Config bucket policies
  #

  statement {
    sid    = "config-permissions-check"
    effect = local.config_effect
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "config-bucket-delivery"
    effect = local.config_effect
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    resources = local.config_resources
  }

  #
  # ELB bucket policies
  #

  statement {
    sid    = "elb-logs-put-object"
    effect = local.elb_effect
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = local.elb_resources
  }

  #
  # ALB bucket policies
  #

  statement {
    sid    = "alb-logs-put-object"
    effect = local.alb_effect
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = local.alb_resources
  }

  #
  # NLB bucket policies
  #

  statement {
    sid    = "nlb-logs-put-object"
    effect = local.nlb_effect
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = local.nlb_resources
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "nlb-logs-acl-check"
    effect = local.nlb_effect
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  #
  # Redshift bucket policies
  #

  statement {
    sid    = "redshift-logs-put-object"
    effect = local.redshift_effect
    principals {
      type        = "AWS"
      identifiers = [local.redshift_principal]
    }
    actions   = ["s3:PutObject"]
    resources = [local.redshift_resource]
  }

  statement {
    sid    = "redshift-logs-get-bucket-acl"
    effect = local.redshift_effect
    principals {
      type        = "AWS"
      identifiers = [local.redshift_principal]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  #
  # Enforce TLS requests only
  #

  statement {
    sid    = "enforce-tls-requests-only"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}


resource "aws_s3_bucket" "aws_logs" {
  bucket        = var.s3_bucket_name
  acl           = var.s3_bucket_acl
  policy        = data.aws_iam_policy_document.main.json
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

  tags = merge(
    var.tags, {
      Name       = var.s3_bucket_name
      Automation = "Terraform"
    }
  )
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
