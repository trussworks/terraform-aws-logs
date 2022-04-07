locals {
  log_bucket_name = "${var.test_name}-logs"
}

module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name

  default_allow = false

  logging_target_bucket = local.log_bucket_name
  logging_target_prefix = var.s3_logs_prefix

  force_destroy = var.force_destroy

  depends_on = [
    module.aws_logs_logs
  ]
}

module "aws_logs_logs" {
  source = "../../"

  s3_bucket_name = local.log_bucket_name

  default_allow = false

  force_destroy = var.force_destroy
}
