module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.logs_bucket
  region         = var.region
}

module "aws_cloudtrail" {
  source         = "trussworks/cloudtrail/aws"
  version        = "~> 2"
  s3_bucket_name = module.aws_logs.aws_logs_bucket
}
