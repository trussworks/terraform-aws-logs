<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates and configures an S3 bucket for storing logs from various AWS
services and enables CloudTrail on all regions. Logs will expire after a
default of 90 days. Includes support for sending CloudTrail events to a
CloudWatch Logs group.

Logging from the following services is supported:

* [CloudTrail](https://aws.amazon.com/cloudtrail/)
* [Config](https://aws.amazon.com/config/)
* [Elastic Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
* [RedShift](https://aws.amazon.com/redshift/)
* [S3](https://aws.amazon.com/s3/)

## Usage

    module "aws_logs" {
      source                  = "trussworks/logs/aws"
      s3_bucket_name          = "my-company-aws-logs"
      region                  = "us-west-2"
      s3_log_bucket_retention = 90
    }

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_logs\_prefix | S3 prefix for ALB logs. | string | `"alb"` | no |
| cloudtrail\_cloudwatch\_logs\_group | The name of the CloudWatch Logs group to send CloudTrail events. | string | `"cloudtrail-events"` | no |
| cloudtrail\_logs\_prefix | S3 prefix for CloudTrail logs. | string | `"cloudtrail"` | no |
| cloudwatch\_log\_group\_retention | Number of days to keep AWS logs around in specific log group. | string | `"90"` | no |
| cloudwatch\_logs\_prefix | S3 prefix for CloudWatch log exports. | string | `"cloudwatch"` | no |
| config\_logs\_prefix | S3 prefix for AWS Config logs. | string | `"config"` | no |
| elb\_logs\_prefix | S3 prefix for ELB logs. | string | `"elb"` | no |
| enable\_alb | Create one bucket with ALB service as the bucket key. | string | `"false"` | no |
| enable\_all\_services | Create one bucket with all services as bucket keys. | string | `"true"` | no |
| enable\_cloudtrail | Enable CloudTrail to log to the AWS logs bucket. | string | `"true"` | no |
| enable\_config | Create one bucket with Config service as the bucket key. | string | `"false"` | no |
| enable\_elb | Create one bucket with ELB service as the bucket key. | string | `"false"` | no |
| enable\_redshift | Create one bucket with Redshift service as the bucket key. | string | `"false"` | no |
| redshift\_logs\_prefix | S3 prefix for RedShift logs. | string | `"redshift"` | no |
| region | Region where the AWS S3 bucket will be created. | string | n/a | yes |
| s3\_bucket\_name | S3 bucket to store AWS logs in. | string | n/a | yes |
| s3\_log\_bucket\_retention | Number of days to keep AWS logs around. | string | `"90"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_logs\_bucket | S3 bucket containing AWS logs. |
| cloudtrail\_cloudwatch\_logs\_arn | The ARN of the CloudWatch Logs group storing CloudTrail Events. |
| cloudtrail\_logs\_path | S3 path for CloudTrail logs. |
| configs\_logs\_path | S3 path for Config logs. |
| elb\_logs\_path | S3 path for ELB logs. |
| redshift\_logs\_path | S3 path for RedShift logs. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
