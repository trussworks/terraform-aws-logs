Supports two main uses cases:

* Creates and configures a single private S3 bucket for storing logs from various AWS services, which are nested as bucket prefixes. Logs will expire after a default of 90 days, with option to configure retention value.
* Creates and configures a single private S3 bucket for a single AWS service. Logs will expire after a default of 90 days, with option to configure retention value.

Logging from the following services is supported for both cases as well as in AWS GovCloud:

* [Application Load Balancer(ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application)
* [Classic Elastic Load Balancer(ELB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic)
* [Network Load Balancer(NLB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network)
* [CloudTrail](https://aws.amazon.com/cloudtrail/)
* [Config](https://aws.amazon.com/config/)
* [RedShift](https://aws.amazon.com/redshift/)
* [S3](https://aws.amazon.com/s3/)

## Terraform Versions

Terraform 0.12. Pin module version to ~> 7.0.0 . Submit pull-requests to master branch.

Terraform 0.11. Pin module version to ~> 3.5.0 . Submit pull-requests to terraform011 branch.

## Usage for a single log bucket storing logs from all services

```hcl
# Allows all services to log to bucket
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs"
  region         = "us-west-2"
}
```

## Usage for a single log bucket storing logs from a single service (ELB in this case)

```hcl
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs-elb"
  region         = "us-west-2"
  default_allow  = false
  allow_elb      = true
}
```

## Usage for a single log bucket storing logs from multiple specified services (ALB and ELB in this case)

```hcl
module "aws_logs" {
  source         = "trussworks/logs/aws"
  s3_bucket_name = "my-company-aws-logs-lb"
  region         = "us-west-2"
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
  region              = "us-west-2"
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
      region            = "us-west-2"
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.70 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_logs\_prefixes | S3 key prefixes for ALB logs. | `list(string)` | <pre>[<br>  "alb"<br>]</pre> | no |
| allow\_alb | Allow ALB service to log to bucket. | `bool` | `false` | no |
| allow\_cloudtrail | Allow Cloudtrail service to log to bucket. | `bool` | `false` | no |
| allow\_cloudwatch | Allow Cloudwatch service to export logs to bucket. | `bool` | `false` | no |
| allow\_config | Allow Config service to log to bucket. | `bool` | `false` | no |
| allow\_elb | Allow ELB service to log to bucket. | `bool` | `false` | no |
| allow\_nlb | Allow NLB service to log to bucket. | `bool` | `false` | no |
| allow\_redshift | Allow Redshift service to log to bucket. | `bool` | `false` | no |
| cloudtrail\_accounts | List of accounts for CloudTrail logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | `string` | `"cloudtrail"` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | `string` | `"cloudwatch"` | no |
| config\_accounts | List of accounts for Config logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | `string` | `"config"` | no |
| create\_public\_access\_block | Whether to create a public\_access\_block restricting public access to the bucket. | `bool` | `true` | no |
| default\_allow | Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write. | `bool` | `true` | no |
| elb\_accounts | List of accounts for ELB logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | `string` | `"elb"` | no |
| force\_destroy | A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error. | `bool` | `false` | no |
| nlb\_logs\_prefixes | S3 key prefixes for NLB logs. | `list(string)` | <pre>[<br>  "nlb"<br>]</pre> | no |
| redshift\_logs\_prefix | S3 prefix for RedShift logs. | `string` | `"redshift"` | no |
| region | Region where the AWS S3 bucket will be created. | `string` | n/a | yes |
| s3\_bucket\_acl | Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list. | `string` | `"log-delivery-write"` | no |
| s3\_bucket\_name | S3 bucket to store AWS logs in. | `string` | n/a | yes |
| s3\_log\_bucket\_retention | Number of days to keep AWS logs around. | `string` | `90` | no |
| tags | A mapping of tags to assign to the logs bucket. Please note that tags with a conflicting key will not override the original tag. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_logs\_bucket | S3 bucket containing AWS logs. |
| configs\_logs\_path | S3 path for Config logs. |
| elb\_logs\_path | S3 path for ELB logs. |
| redshift\_logs\_path | S3 path for RedShift logs. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Upgrade Paths

### Upgrading from 6.0.0 to 7.x.x

This release simplifies `nlb_logs_prefixes` and `alb_logs_prefixes` to no longer need to pass in a formatted list and instead can be referenced as

```hcl
nlb_logs_prefixes = [
 "nlb/hello-world-prod",
 "nlb/hello-world-staging",
 "nlb/hello-world-experimental",
]
```

This release defines more restrictive bucket policies for ALB and NLB logs to include the AWS account id to the allowed path. Terraform plans with this version of the module will look something like

```text
~ Resource  = "arn:aws:s3:::bucket-a-us-west-2/nlb/*" -> "arn:aws:s3:::bucket-a-us-west-2/nlb/AWSLogs/480766629331/*"
```

### Upgrading from 5.0.0 to 5.1.x

Version 5.1.0 removed the `nlb_logs_prefix` and `nlb_accounts` variables and now uses one `nlb_logs_prefixes` list as input.  If you had not set the `nlb_logs_prefix` or `nlb_accounts` variables, then the default behavior does not change.  If you had set `nlb_logs_prefix`, then simply pass the original value as a 1 item list to `nlb_logs_prefixes` (while watching that path separators are not duplicated).  For example, `nlb_logs_prefixes = ["logs/nlb"]`.

Use the `format` and `formatlist` functions in the caller module to support more complex logging that does limit by account id.  For example:

```hcl
    nlb_logs_prefixes = formatlist(format("nlb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
      "hello-world-prod",
      "hello-world-staging",
      "hello-world-experimental",
    ])
```

### Upgrading from 4.0.0 to 4.1.x

Version 4.1.0 removed the `aws_s3_bucket_policy` resource and now applies the bucket policy directly to the
`aws_s3_bucket` resource to address an operation ordering issue when creating a cloudtrail and logs bucket in the same
`terraform apply`. Upgrading a bucket to use version 4.1.0 of the module will update the bucket in-place, but will
destroy and recreate the bucket policy.

### 4.0.0

Version 4.0.0 upgraded to Terraform 12 syntax.

### Upgrading from 3.4.0 to 3.5.x

Version 3.5.0 removed the `alb_logs_prefix` and `alb_accounts` variables and now uses one `alb_logs_prefixes` list as input.  If you had not set the `alb_logs_prefix` or `alb_accounts` variables, then the default behavior does not change.  If you had set `alb_logs_prefix`, then simply pass the original value as a 1 item list to `alb_logs_prefixes` (while watching that path separators are not duplicated).  For example, `alb_logs_prefixes = ["logs/alb"]`.

Use the `format` and `formatlist` functions in the caller module to support more complex logging that does limit by account id.  For example:

```hcl
    alb_logs_prefixes = formatlist(format("alb/%%s/AWSLogs/%s", data.aws_caller_identity.current.account_id), [
      "hello-world-prod",
      "hello-world-staging",
      "hello-world-experimental",
    ])
```

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

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```shell
make test
```

Or with aws-vault:

```shell
AWS_VAULT_KEYCHAIN_NAME=login aws-vault exec YOUR-AWS-PROFILE -- make test
```
