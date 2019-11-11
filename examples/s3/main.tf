module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.logs_bucket
  region         = var.region
}

resource "aws_s3_bucket" "log_source_bucket" {
  acl = "private"

  logging {
    target_bucket = module.aws_logs.aws_logs_bucket
    target_prefix = "log/"
  }
}