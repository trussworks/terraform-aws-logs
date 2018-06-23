Creates and configures an S3 bucket for storing logs from various AWS
services and enables CloudTrail on all regions. Logs will expire after a
default of 90 days.

Logging from the following services is supported:

* [CloudTrail](https://aws.amazon.com/cloudtrail/)
* [Config](https://aws.amazon.com/config/)
* [Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
* [RedShift](https://aws.amazon.com/redshift/)
* [S3](https://aws.amazon.com/s3/)

## Usage

    module "aws_logs" {
      source         = "trussworks/aws/logs"
      s3_bucket_name = "my-company-aws-logs"
      region         = "us-west-2"
      expiration     = 90
    }


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_logs_prefix | S3 prefix for ALB logs. | string | `alb` | no |
| cloudtrail_logs_prefix | S3 prefix for CloudTrail logs. | string | `cloudtrail` | no |
| config_logs_prefix | S3 prefix for AWS Config logs. | string | `config` | no |
| elb_logs_prefix | S3 prefix for ELB logs. | string | `elb` | no |
| expiration | Number of days to keep AWS logs around. | string | `90` | no |
| redshift_logs_prefix | S3 prefix for RedShift logs. | string | `redshift` | no |
| region | Region where the AWS S3 bucket will be created. | string | - | yes |
| s3_bucket_name | S3 bucket to store AWS logs in. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws_logs_bucket | S3 bucket containing AWS logs. |
| cloudtrail_logs_path | S3 path for CloudTrail logs. |
| configs_logs_path | S3 path for Config logs. |
| elb_logs_path | S3 path for ELB logs. |
| redshift_logs_path | S3 path for RedShift logs. |

