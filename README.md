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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
