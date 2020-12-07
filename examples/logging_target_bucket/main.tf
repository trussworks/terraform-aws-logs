module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name

  default_allow = false

  logging_target_bucket = module.aws_logs_logs.aws_logs_bucket
  logging_target_prefix = var.s3_logs_prefix

  force_destroy = var.force_destroy
}

module "aws_logs_logs" {
  source = "../../"

  s3_bucket_name = "${var.test_name}-logs"

  default_allow = false

  force_destroy = var.force_destroy
}
