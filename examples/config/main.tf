module "aws_logs" {
  source             = "../../"
  s3_bucket_name     = var.logs_bucket
  region             = var.region
  allow_config       = "true"
  config_logs_prefix = "config"
}

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 2"

  config_logs_bucket = module.aws_logs.aws_logs_bucket
  config_logs_prefix = "config"
}
