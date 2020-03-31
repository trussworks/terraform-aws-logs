module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name
  region         = var.region

  force_destroy = var.force_destroy
}
