module "aws_logs" {
  source = "../../"

  s3_bucket_name        = var.test_name
  allow_guardduty       = true
  default_allow         = false
  guardduty_logs_prefix = var.guardduty_logs_prefix

  force_destroy = var.force_destroy
}

module "guardduty" {
  source  = "dod-iac/guardduty/aws"
  version = "~> 1"

  s3_bucket_name = module.aws_logs.aws_logs_bucket
}
