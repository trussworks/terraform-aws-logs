module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name

  enable_versioning = true

  force_destroy = var.force_destroy
  tags          = var.tags
}
