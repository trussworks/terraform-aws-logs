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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.aws_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
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
| <a name="input_alb_account"></a> [alb\_account](#input\_alb\_account) | Account for ALB logs.  By default limits to the current account. | `string` | `""` | no |
| <a name="input_alb_logs_prefixes"></a> [alb\_logs\_prefixes](#input\_alb\_logs\_prefixes) | S3 key prefixes for ALB logs. | `list(string)` | <pre>[<br>  "alb"<br>]</pre> | no |
| <a name="input_allow_alb"></a> [allow\_alb](#input\_allow\_alb) | Allow ALB service to log to bucket. | `bool` | `false` | no |
| <a name="input_allow_cloudtrail"></a> [allow\_cloudtrail](#input\_allow\_cloudtrail) | Allow Cloudtrail service to log to bucket. | `bool` | `false` | no |
| <a name="input_allow_cloudwatch"></a> [allow\_cloudwatch](#input\_allow\_cloudwatch) | Allow Cloudwatch service to export logs to bucket. | `bool` | `false` | no |
| <a name="input_allow_config"></a> [allow\_config](#input\_allow\_config) | Allow Config service to log to bucket. | `bool` | `false` | no |
| <a name="input_allow_elb"></a> [allow\_elb](#input\_allow\_elb) | Allow ELB service to log to bucket. | `bool` | `false` | no |
| <a name="input_allow_nlb"></a> [allow\_nlb](#input\_allow\_nlb) | Allow NLB service to log to bucket. | `bool` | `false` | no |
| <a name="input_allow_redshift"></a> [allow\_redshift](#input\_allow\_redshift) | Allow Redshift service to log to bucket. | `bool` | `false` | no |
| <a name="input_cloudtrail_accounts"></a> [cloudtrail\_accounts](#input\_cloudtrail\_accounts) | List of accounts for CloudTrail logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_logs_prefix"></a> [cloudtrail\_logs\_prefix](#input\_cloudtrail\_logs\_prefix) | S3 prefix for CloudTrail logs. | `string` | `"cloudtrail"` | no |
| <a name="input_cloudtrail_org_id"></a> [cloudtrail\_org\_id](#input\_cloudtrail\_org\_id) | AWS Organization ID for CloudTrail. | `string` | `""` | no |
| <a name="input_cloudwatch_logs_prefix"></a> [cloudwatch\_logs\_prefix](#input\_cloudwatch\_logs\_prefix) | S3 prefix for CloudWatch log exports. | `string` | `"cloudwatch"` | no |
| <a name="input_config_accounts"></a> [config\_accounts](#input\_config\_accounts) | List of accounts for Config logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| <a name="input_config_logs_prefix"></a> [config\_logs\_prefix](#input\_config\_logs\_prefix) | S3 prefix for AWS Config logs. | `string` | `"config"` | no |
| <a name="input_create_public_access_block"></a> [create\_public\_access\_block](#input\_create\_public\_access\_block) | Whether to create a public\_access\_block restricting public access to the bucket. | `bool` | `true` | no |
| <a name="input_default_allow"></a> [default\_allow](#input\_default\_allow) | Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write. | `bool` | `true` | no |
| <a name="input_elb_accounts"></a> [elb\_accounts](#input\_elb\_accounts) | List of accounts for ELB logs.  By default limits to the current account. | `list(string)` | `[]` | no |
| <a name="input_elb_logs_prefix"></a> [elb\_logs\_prefix](#input\_elb\_logs\_prefix) | S3 prefix for ELB logs. | `string` | `"elb"` | no |
| <a name="input_enable_mfa_delete"></a> [enable\_mfa\_delete](#input\_enable\_mfa\_delete) | A bool that requires MFA to delete the log bucket. | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error. | `bool` | `false` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | S3 Bucket to send S3 logs to. Disables logging if omitted. | `string` | `""` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Prefix for logs going into the log\_s3\_bucket. | `string` | `"s3/"` | no |
| <a name="input_nlb_account"></a> [nlb\_account](#input\_nlb\_account) | Account for NLB logs.  By default limits to the current account. | `string` | `""` | no |
| <a name="input_nlb_logs_prefixes"></a> [nlb\_logs\_prefixes](#input\_nlb\_logs\_prefixes) | S3 key prefixes for NLB logs. | `list(string)` | <pre>[<br>  "nlb"<br>]</pre> | no |
| <a name="input_noncurrent_version_retention"></a> [noncurrent\_version\_retention](#input\_noncurrent\_version\_retention) | Number of days to retain non-current versions of objects if versioning is enabled. | `string` | `30` | no |
| <a name="input_redshift_logs_prefix"></a> [redshift\_logs\_prefix](#input\_redshift\_logs\_prefix) | S3 prefix for RedShift logs. | `string` | `"redshift"` | no |
| <a name="input_s3_bucket_acl"></a> [s3\_bucket\_acl](#input\_s3\_bucket\_acl) | Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list. | `string` | `"log-delivery-write"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket to store AWS logs in. | `string` | n/a | yes |
| <a name="input_s3_log_bucket_retention"></a> [s3\_log\_bucket\_retention](#input\_s3\_log\_bucket\_retention) | Number of days to keep AWS logs around. | `string` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the logs bucket. Please note that tags with a conflicting key will not override the original tag. | `map(string)` | `{}` | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | A string that indicates the versioning status for the log bucket. | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_logs_bucket"></a> [aws\_logs\_bucket](#output\_aws\_logs\_bucket) | ID of the S3 bucket containing AWS logs. |
| <a name="output_configs_logs_path"></a> [configs\_logs\_path](#output\_configs\_logs\_path) | S3 path for Config logs. |
| <a name="output_elb_logs_path"></a> [elb\_logs\_path](#output\_elb\_logs\_path) | S3 path for ELB logs. |
| <a name="output_redshift_logs_path"></a> [redshift\_logs\_path](#output\_redshift\_logs\_path) | S3 path for RedShift logs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Upgrade Paths

### Upgrading from 11.x.x to 13.x.x

We advise upgrading directly from 11.x.x to 13.x.x for the smoothest upgrade experience.

Version 13.x.x enables the use of version 4 of the AWS provider. Terraform provided [an upgrade path](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade) for this. To support the upgrade path, this module now includes the following additional resources:

* `aws_s3_bucket_policy.aws_logs`
* `aws_s3_bucket_acl.aws_logs`
* `aws_s3_bucket_lifecycle_configuration.aws_logs`
* `aws_s3_bucket_server_side_encryption_configuration.aws_logs`
* `aws_s3_bucket_logging.aws_logs`
* `aws_s3_bucket_versioning.aws_logs`

This module version removes the `enable_versioning` variable (boolean) and replaces it with the `versioning_status` variable (string). There are three possible values for this variable: `Enabled`, `Disabled`, and `Suspended`. If at one point versioning was enabled on your bucket, but has since been turned off, you will need to set `versioning_status` to `Suspended` rather than `Disabled`.

Additionally, this version of the module requires a minimum AWS provider version of 3.75, so that you can remain on the 3.x AWS provider while still gaining the ability to utilize the new S3 resources introduced in the 4.x AWS provider.

There are two general approaches to performing this upgrade:

1. Upgrade the module version and run `terraform plan` followed by `terraform apply`, which will create the new Terraform resources.
1. Perform `terraform import` commands, which accomplishes the same thing without running `terraform apply`. This is the more cautious route.

If you choose to take the route of running `terraform import`, you will need to perform the following imports. Replace `example` with the name you're using when calling this module and replace `your-bucket-name-here` with the name of your bucket (as opposed to an S3 bucket ARN). Also note the inclusion of `,log-delivery-write` when importing the new `aws_s3_bucket_acl` Terraform resource; if you are setting the `s3_bucket_acl` input variable, use that value instead of `log-delivery-write`. If you have not configured a target bucket using the `logging_target_bucket` input variable, then you don't need to import the aws_s3_bucket_logging Terraform resource.

```sh
terraform import module.example.aws_s3_bucket_policy.aws_logs your-bucket-name-here
# If you have configured the s3_bucket_acl input variable, replace log-delivery-write with the value you are using for s3_bucket_acl.
terraform import module.example.aws_s3_bucket_acl.aws_logs your-bucket-name-here,log-delivery-write
terraform import module.example.aws_s3_bucket_lifecycle_configuration.aws_logs your-bucket-name-here
terraform import module.example.aws_s3_bucket_server_side_encryption_configuration.aws_logs your-bucket-name-here
terraform import module.example.aws_s3_bucket_versioning.aws_logs your-bucket-name-here
# Optionally run this command if you have configured the logging_target_bucket input variable.
terraform import module.example.aws_s3_bucket_logging.aws_logs your-target-bucket-name-here
```

### Upgrading from 10.x.x to 11.x.x

Version 11.x.x removes the use of the `Automation` tag with a value of `"Terraform"`. If you would like to continue using the `Automation` tag, you can define it directly in `var.tags`.

### Upgrading from 9.0.0 to 10.x.x

Version 10.x.x removes the `region` variable as it will pull from the region that your AWS session is associated with.

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

# A Note About NLB Access Logs

NLB Access logs are created only if the load balancer has a client request-based [TLS listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html). Also, the logs will only contain information about TLS requests. See the AWS [Documentation on Access Logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html) for further details.

If you're using mTLS to exchange a mutually-trusted Certificate Authority, you may require a TCP listener. While it's true that TLS runs over TCP, for mTLS each new successive connection requires two roundtrips to complete the "full handshake." No NLB access logs will be created in this case.
