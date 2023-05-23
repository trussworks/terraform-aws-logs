Supports two main uses cases:

- Creates and configures a single private S3 bucket for storing logs from various AWS services, which are nested as bucket prefixes. Logs will expire after a default of 90 days, with option to configure retention value.
- Creates and configures a single private S3 bucket for a single AWS service. Logs will expire after a default of 90 days, with option to configure retention value.

Logging from the following services is supported for both cases as well as in AWS GovCloud:

- [Application Load Balancer(ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application)
- [Classic Elastic Load Balancer(ELB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic)
- [Network Load Balancer(NLB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network)
- [CloudTrail](https://aws.amazon.com/cloudtrail/)
- [Config](https://aws.amazon.com/config/)
- [RedShift](https://aws.amazon.com/redshift/)
- [S3](https://aws.amazon.com/s3/)

## Usage for a single log bucket storing logs from all services

```hcl
# Allows all services to log to bucket
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs"
}
```

## Usage for a single log bucket storing logs from a single service (ELB in this case)

```hcl
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs-elb"
  default_allow  = false
  allow_elb      = true
}
```

## Usage for a single log bucket storing logs from multiple specified services (ALB and ELB in this case)

```hcl
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs-lb"
  default_allow  = false
  allow_alb      = true
  allow_elb      = true
}
```

## Usage for a single log bucket storing CloudTrail logs from multiple accounts

```hcl
module "aws_logs" {
  source              = "trussworks/logs/aws"
  s3_bucket_name      = "my-company-aws-logs-cloudtrail"
  default_allow       = false
  allow_cloudtrail    = true
  cloudtrail_accounts = [data.aws_caller_identity.current.account_id, aws_organizations_account.example.id]
}
```

## Usage for a single log bucket storing logs from multiple application load balancers (ALB) and network load balancers (NLB)

```hcl
module "aws_logs" {
  source            = "trussworks/logs/aws"
  s3_bucket_name    = "my-company-aws-logs-lb"
      default_allow     = false
      allow_alb         = true
      allow_nlb         = true
      alb_logs_prefixes = [
       "alb/hello-world-prod",
       "alb/hello-world-staging",
       "alb/hello-world-experimental",
      ]
      nlb_logs_prefixes = [
       "nlb/hello-world-prod",
       "nlb/hello-world-staging",
       "nlb/hello-world-experimental",
      ]
    }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_redshift_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/redshift_service_account) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_account | Account for ALB logs.  By default limits to the current account. | `string` | `""` | no |
| alb\_logs\_prefixes | S3 key prefixes for ALB logs. | `list(string)` | ```[ "alb" ]``` | no |
| allow\_alb | Allow ALB service to log to bucket. | `bool` | `false` | no |
| allow\_cloudtrail | Allow Cloudtrail service to log to bucket. | `bool` | `false` | no |
| allow\_cloudwatch | Allow Cloudwatch service to export logs to bucket. | `bool` | `false` | no |
| allow\_config | Allow Config service to log to bucket. | `bool` | `false` | no |
| allow\_elb | Allow ELB service to log to bucket. | `bool` | `false` | no |
| allow\_nlb | Allow NLB service to log to bucket. | `bool` | `false` | no |
| allow\_redshift | Allow Redshift service to log to bucket. | `bool` | `false` | no |
| allow\_s3 | Allow S3 service to log to bucket. | `bool` | `false` | no |
| cloudtrail\_accounts | List of accounts for CloudTrail logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | `string` | `"cloudtrail"` | no |
| cloudtrail\_org\_id | AWS Organization ID for CloudTrail. | `string` | `""` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | `string` | `"cloudwatch"` | no |
| config\_accounts | List of accounts for Config logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | `string` | `"config"` | no |
| control\_object\_ownership | Whether to manage S3 Bucket Ownership Controls on this bucket. | `bool` | `true` | no |
| create\_public\_access\_block | Whether to create a public\_access\_block restricting public access to the bucket. | `bool` | `true` | no |
| default\_allow | Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write. | `bool` | `true` | no |
| elb\_accounts | List of accounts for ELB logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | `string` | `"elb"` | no |
| enable\_mfa\_delete | A bool that requires MFA to delete the log bucket. | `bool` | `false` | no |
| enable\_s3\_log\_bucket\_lifecycle\_rule | Whether the lifecycle rule for the log bucket is enabled. | `bool` | `true` | no |
| force\_destroy | A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error. | `bool` | `false` | no |
| logging\_target\_bucket | S3 Bucket to send S3 logs to. Disables logging if omitted. | `string` | `""` | no |
| logging\_target\_prefix | Prefix for logs going into the log\_s3\_bucket. | `string` | `"s3/"` | no |
| nlb\_account | Account for NLB logs.  By default limits to the current account. | `string` | `""` | no |
| nlb\_logs\_prefixes | S3 key prefixes for NLB logs. | `list(string)` | ```[ "nlb" ]``` | no |
| noncurrent\_version\_retention | Number of days to retain non-current versions of objects if versioning is enabled. | `string` | `30` | no |
| object\_ownership | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. | `string` | `"BucketOwnerEnforced"` | no |
| redshift\_logs\_prefix | S3 prefix for RedShift logs. | `string` | `"redshift"` | no |
| s3\_bucket\_acl | Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list. | `string` | `null` | no |
| s3\_bucket\_name | S3 bucket to store AWS logs in. | `string` | n/a | yes |
| s3\_log\_bucket\_retention | Number of days to keep AWS logs around. | `string` | `90` | no |
| s3\_logs\_prefix | S3 prefix for S3 access logs. | `string` | `"s3"` | no |
| tags | A mapping of tags to assign to the logs bucket. Please note that tags with a conflicting key will not override the original tag. | `map(string)` | `{}` | no |
| versioning\_status | A string that indicates the versioning status for the log bucket. | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_logs\_bucket | ID of the S3 bucket containing AWS logs. |
| bucket\_arn | ARN of the S3 logs bucket |
| configs\_logs\_path | S3 path for Config logs. |
| elb\_logs\_path | S3 path for ELB logs. |
| redshift\_logs\_path | S3 path for RedShift logs. |
| s3\_bucket\_policy | S3 bucket policy |
<!-- END_TF_DOCS -->

## Upgrade Paths

### Upgrading from 14.x.x to 15.x.x

Version 15.x.x updates the module to account for changes made by AWS in April
2023 to the default security settings of new S3 buckets.

Version 15.x.x of this module adds the following resource and variables. How to
use the new variables will depend on your use case.

New resource:

- `aws_s3_bucket_ownership_controls.aws_logs`

New variables:

- `allow_s3`
- `control_object_ownership`
- `object_ownership`
- `s3_bucket_acl`
- `s3_logs_prefix`

Steps for updating existing buckets managed by this module:

- **Option 1: Disable ACLs.** This module's default values for
  `control_object_ownership`, `object_ownership`, and `s3_bucket_acl` follow the
  new AWS recommended best practice. For a new S3 bucket, using those settings
  will disable S3 access control lists for the bucket and set object ownership
  to `BucketOwnerEnforced`. For an existing bucket that is used to store s3
  server access logs, the bucket ACL permissions for the S3 log delivery group
  must be migrated to the bucket policy. The changes must be applied
  in multiple steps.

Step 1: Update the log bucket policy to grant `s3:PutObject` permission to the
logging service principal (`logging.s3.amazonaws.com`).

  Example:

```text
  statement {
    sid    = "s3-logs-put-object"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["BUCKET_ARN_PLACEHOLDER/LOGGING_PREFIX_PLACEHOLDER/*"]
  }
```

Step 2: Change `s3_bucket_acl` to `private`.

Step 3: Change `object_ownership` to `BucketOwnerEnforced`.

- **Option 2: Continue using ACLs.** To continue using ACLs, set `s3_bucket_acl`
  to `"log-delivery-write"` and set `object_ownership` to `ObjectWriter` or
  `BucketOwnerPreferred`.

See [Controlling ownership of objects and disabling ACLs for your
bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html)
for further details and migration considerations.
