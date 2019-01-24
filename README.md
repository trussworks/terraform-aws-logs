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

## Usage for a single log bucket storing logs from multiple services

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
      default_allow = false
      allow_elb     = true
    }

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_logs\_prefix | S3 prefix for ALB logs. | string | `alb` | no |
| allow\_alb | Allow ALB service to log to bucket. | string | `false` | no |
| allow\_cloudtrail | Allow Cloudtrail service to log to bucket. | string | `false` | no |
| allow\_cloudwatch | Allow Cloudwatch service to log to bucket. | string | `false` | no |
| allow\_config | Allow Config service to log to bucket. | string | `false` | no |
| allow\_elb | Allow ELB service to log to bucket. | string | `false` | no |
| allow\_redshift | Allow Redshift service to log to bucket. | string | `false` | no |
| allow\_s3 | Allow S3 service to log to bucket. | string | `false` | no |
| cloudtrail\_cloudwatch\_logs\_group | The name of the CloudWatch Logs group to send CloudTrail events. | string | `cloudtrail-events` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | string | `cloudtrail` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | string | `cloudwatch` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | string | `config` | no |
| default\_allow | Whether all services should be allowed by default. Individual services can override this default. | string | `true` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | string | `elb` | no |
| redshift\_logs\_prefix | S3 prefix for RedShift logs. | string | `redshift` | no |
| region | Region where the AWS S3 bucket will be created. | string | - | yes |
| s3\_bucket\_name | S3 bucket to store AWS logs in. | string | - | yes |
| s3\_log\_bucket\_retention | Number of days to keep AWS logs around. | string | `90` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_logs\_bucket | S3 bucket containing AWS logs. |
| configs\_logs\_path | S3 path for Config logs. |
| elb\_logs\_path | S3 path for ELB logs. |
| redshift\_logs\_path | S3 path for RedShift logs. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
