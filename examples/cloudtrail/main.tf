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
  version = "~> 3.0"

  s3_bucket_name            = module.aws_logs.aws_logs_bucket
  cloudwatch_log_group_name = var.test_name
  s3_key_prefix             = var.cloudtrail_logs_prefix
}
