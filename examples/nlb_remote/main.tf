# Testing the log bucket has a certain policy. Spinning up an ALB won't work as the
# s3 prefix is different since the ALB will be using local Account ID, not the
# external_account
module "aws_logs" {
  source = "../../"

  s3_bucket_name    = var.test_name
  nlb_logs_prefixes = var.nlb_logs_prefixes
  allow_nlb         = true
  default_allow     = false

  nlb_account = var.nlb_external_account

  force_destroy = var.force_destroy
}
