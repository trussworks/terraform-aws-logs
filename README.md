<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Supports two main uses cases:

1. Creates and configures a single private S3 bucket for storing logs from various AWS services, which are nested as bucket prefixes. Logs will expire after a default of 90 days, with option to configure retention value.
1. Creates and configures a single private S3 bucket for a single AWS service. Logs will expire after a default of 90 days, with option to configure retention value.

Logging from the following services is supported for both cases:

* [CloudTrail](https://aws.amazon.com/cloudtrail/)
* [Config](https://aws.amazon.com/config/)
* [Classic Load Balancer (ELB) and Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/)
* [RedShift](https://aws.amazon.com/redshift/)
* [S3](https://aws.amazon.com/s3/)

## Usage for a single log bucket storing logs from all services

    # Allows all services to log to bucket
    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs"
      region         = "us-west-2"
    }

## Usage for a single log bucket storing logs from a single service

    #  Allows only the service specified (elb in this case) to log to the bucket
    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs-elb"
      region         = "us-west-2"
      default_allow  = false
      allow_elb      = true
    }

## Usage for a single log bucket storing logs from multiple specified services

    #  Allows only the services specified (alb and elb in this case) to log to the bucket
    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs-elb"
      region         = "us-west-2"
      default_allow  = false
      allow_alb      = true
      allow_elb      = true
    }

## Usage for a private bucket with no policies

    #  Allows no services to log to the bucket
    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs-elb"
      s3_bucket_acl  = "private"
      region         = "us-west-2"
      default_allow  = false
    }

## Usage for a single log bucket storing logs from multiple accounts

    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs-elb"
      region         = "us-west-2"
      default_allow  = false
      allow_cloudtrail      = true
      cloudtrail_accounts = ["${data.aws_caller_identity.current.account_id}", "${aws_organizations_account.example.id}"]
    }

## Usage for a single log bucket storing logs from multiple application load balancers

    module "aws_logs" {
      source         = "trussworks/logs/aws"
      s3_bucket_name = "my-company-aws-logs-alb"
      region         = "us-west-2"
      default_allow  = false
      allow_alb      = true
      alb_logs_prefixes = formatlist(format("alb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
       "hello-world-prod",
       "hello-world-staging",
       "hello-world-experimental",
      ])
    }

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_logs\_prefixes | S3 key prefixes for ALB logs. | list | `[ "alb" ]` | no |
| allow\_alb | Allow ALB service to log to bucket. | string | `"false"` | no |
| allow\_cloudtrail | Allow Cloudtrail service to log to bucket. | string | `"false"` | no |
| allow\_cloudwatch | Allow Cloudwatch service to export logs to bucket. | string | `"false"` | no |
| allow\_config | Allow Config service to log to bucket. | string | `"false"` | no |
| allow\_elb | Allow ELB service to log to bucket. | string | `"false"` | no |
| allow\_nlb | Allow NLB service to log to bucket. | string | `"false"` | no |
| allow\_redshift | Allow Redshift service to log to bucket. | string | `"false"` | no |
| cloudtrail\_accounts | List of accounts for CloudTrail logs.  By default limits to the current account. | list | `[]` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | string | `"cloudtrail"` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | string | `"cloudwatch"` | no |
| config\_accounts | List of accounts for Config logs.  By default limits to the current account. | list | `[]` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | string | `"config"` | no |
| create\_public\_access\_block | Whether to create a public_access_block restricting public access to the bucket. | string | `"true"` | no |
| default\_allow | Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write. | string | `"true"` | no |
| elb\_accounts | List of accounts for ELB logs.  By default limits to the current account. | list | `[]` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | string | `"elb"` | no |
| nlb\_accounts | List of accounts for NLB logs.  By default limits to the current account. | list | `[]` | no |
| nlb\_logs\_prefix | S3 prefix for NLB logs. | string | `"nlb"` | no |
| redshift\_logs\_prefix | S3 prefix for RedShift logs. | string | `"redshift"` | no |
| region | Region where the AWS S3 bucket will be created. | string | n/a | yes |
| s3\_bucket\_acl | Set bucket ACL per [AWS S3 Canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) list. | string | `"log-delivery-write"` | no |
| s3\_bucket\_name | S3 bucket to store AWS logs in. | string | n/a | yes |
| s3\_log\_bucket\_retention | Number of days to keep AWS logs around. | string | `"90"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_logs\_bucket | S3 bucket containing AWS logs. |
| configs\_logs\_path | S3 path for Config logs. |
| elb\_logs\_path | S3 path for ELB logs. |
| redshift\_logs\_path | S3 path for RedShift logs. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Upgrade Paths

### Upgrading from 3.4.0 to 3.5.x

Version 3.5.0 removed the `alb_logs_prefix` and `alb_accounts` variables and now uses one `alb_logs_prefixes` list as input.  If you had not set the `alb_logs_prefix` or `alb_accounts` variables, then the default behavior does not change.  If you had set `alb_logs_prefix`, then simply pass the original value as a 1 item list to `alb_logs_prefixes` (while watching that path separators are not duplicated).  For example, `alb_logs_prefixes = ["logs/alb"]`.

Use the `format` and `formatlist` functions in the caller module to support more complex logging that does limit by account id.  For example:

    alb_logs_prefixes = formatlist(format("alb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
      "hello-world-prod",
      "hello-world-staging",
      "hello-world-experimental",
    ])

### Upgrading from 2.1.X to 3.X.X

Before upgrading you will want to make sure you are on the latest version of 2.1.X.

The variable `allow_s3` has been removed. If you were using the variable `allow_s3` to manage the bucket ACL or policy
creation you'll want to make changes as the variable has been removed. For the bucket ACL you will now use
`s3_bucket_acl` which is set to `log-delivery-write` by default. If you had `default_allow=false` and `allow_s3=false`
you'll want to set `s3_bucket_acl="private"`.

If you are using `default_allow=true` you can skip the rest of this upgrade guide.

As for policy creation, all policies are now turned on or off via the `allow_*` variables. By setting these to `true`
the `effect` block in the bucket policy for that resource will be modified to `Allow` whereas by default it will be
set to `Deny`. Previously this module used a template to add or remove JSON text from the policy before rendering.
The new module explicitly adds all resource policies as `Deny` and leaves it up to you to enable them.
