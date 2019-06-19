<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_logs\_prefix | S3 prefix for ALB logs. | string | `"alb"` | no |
| allow\_alb | Allow ALB service to log to bucket. | string | `"false"` | no |
| allow\_cloudtrail | Allow Cloudtrail service to log to bucket. | string | `"false"` | no |
| allow\_cloudwatch | Allow Cloudwatch service to export logs to bucket. | string | `"false"` | no |
| allow\_config | Allow Config service to log to bucket. | string | `"false"` | no |
| allow\_elb | Allow ELB service to log to bucket. | string | `"false"` | no |
| allow\_redshift | Allow Redshift service to log to bucket. | string | `"false"` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | string | `"cloudtrail"` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | string | `"cloudwatch"` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | string | `"config"` | no |
| default\_allow | Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write. | string | `"true"` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | string | `"elb"` | no |
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
