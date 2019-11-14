module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.test_name
  region         = var.region
  allow_redshift = "true"
}

resource "aws_redshift_cluster" "test_redshift" {
  cluster_identifier  = var.test_name
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  master_username     = "testredshiftuser"
  master_password     = "TestRedshiftpw123"
  skip_final_snapshot = "true"

  logging {
    bucket_name   = module.aws_logs.aws_logs_bucket
    s3_key_prefix = "redshift"
    enable        = true
  }
}
