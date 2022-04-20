module "aws_logs" {
  source = "../../"

  s3_bucket_name         = var.test_name
  force_destroy          = var.force_destroy
  cloudtrail_logs_prefix = var.cloudtrail_logs_prefix

  default_allow    = false
  allow_cloudtrail = true
}

module "aws_cloudtrail" {
  source  = "trussworks/cloudtrail/aws"
  version = "~> 4"

  iam_role_name             = "cloudtrail-cloudwatch-logs-role-${var.test_name}"
  s3_bucket_name            = module.aws_logs.aws_logs_bucket
  s3_key_prefix             = var.cloudtrail_logs_prefix
  cloudwatch_log_group_name = var.test_name
  trail_name                = "cloudtrail-${var.test_name}"
  iam_policy_name           = "cloudtrail-cloudwatch-logs-policy-${var.test_name}"
}
