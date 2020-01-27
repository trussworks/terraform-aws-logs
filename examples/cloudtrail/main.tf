module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.test_name
  region         = var.region
  force_destroy  = var.force_destroy
}

module "aws_cloudtrail" {
  source                    = "trussworks/cloudtrail/aws"
  version                   = "~> 2"
  s3_bucket_name            = module.aws_logs.aws_logs_bucket
  cloudwatch_log_group_name = var.test_name
}
