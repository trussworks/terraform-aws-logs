Module that sets up a single S3 bucket for storing logs from various AWS
services and enables CloudTrail on all regions. Logs will expire after
a default of 90 days.

Logging from the following services is supported:
 * CloudTrail - https://aws.amazon.com/cloudtrail/
 * ELB - https://aws.amazon.com/elasticloadbalancing/
 * RedShift - https://aws.amazon.com/redshift/
 * Config - https://aws.amazon.com/config/

Usage:

    module "aws_logs" {
      source         = "../modules/aws_logs"
      s3_bucket_name = "truss-aws-logs"
      region         = "us-west-2"
      expiration     = 90
    }



## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| s3_bucket_name | The name of the s3 bucket that will be used for AWS logs | - | yes |
| region | The region where the AWS S3 bucket will be created | - | yes |
| expiration | The number of days to keep AWS logs around | `90` | no |
| elb_logs_prefix | The S3 prefix for ELB logs | `elb` | no |
| cloudtrail_logs_prefix | The S3 prefix for CloudTrail logs | `cloudtrail` | no |
| redshift_logs_prefix | The S3 prefix for RedShift logs | `redshift` | no |
| config_logs_prefix | The S3 prefix for AWS Config logs | `config` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws_logs_bucket | AWS logs S3 bucket name |
| cloudtrail_logs_path | S3 path for cloudtrail logs |
| elb_logs_path | S3 path for ELB logs |
| redshift_logs_path | S3 path for RedShift logs |
| configs_logs_path | S3 path for Config logs |

