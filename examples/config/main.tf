module "aws_logs" {
  source             = "../../"
  s3_bucket_name     = var.test_name
  region             = var.region
  allow_config       = "true"
  config_logs_prefix = "config"
  force_destroy      = var.force_destroy
}

module "config" {
  source             = "trussworks/config/aws"
  version            = "~> 2"
  config_name        = var.test_name
  config_logs_bucket = module.aws_logs.aws_logs_bucket
  config_logs_prefix = "config"
}
