module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name
  region         = var.region

  default_allow = false

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "log_source_bucket" {
  bucket = "${var.test_name}-source"
  acl    = "private"

  logging {
    target_bucket = module.aws_logs.aws_logs_bucket
    target_prefix = var.s3_logs_prefix
  }
}
