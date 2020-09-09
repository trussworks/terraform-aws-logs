module "aws_logs" {
  source = "../../"

  s3_bucket_name     = var.test_name
  allow_config       = true
  default_allow      = false
  config_logs_prefix = var.config_logs_prefix

  force_destroy = var.force_destroy
}


module "config" {
  source  = "trussworks/config/aws"
  version = "~> 4"

  config_name        = var.test_name
  config_logs_bucket = module.aws_logs.aws_logs_bucket
  config_logs_prefix = var.config_logs_prefix
}
