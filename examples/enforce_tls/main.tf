module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name
  region         = var.region

  enforce_tls_requests_only = var.enforce_tls_requests_only

  force_destroy = var.force_destroy
}
