module "aws_logs" {
  source = "../../"

  s3_bucket_name       = var.test_name
  redshift_logs_prefix = var.redshift_logs_prefix
  region               = var.region
  allow_redshift       = true
  default_allow        = false

  force_destroy = true
}

resource "aws_redshift_cluster" "test_redshift" {
  cluster_identifier        = var.test_name
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  master_username           = "testredshiftuser"
  master_password           = "TestRedshiftpw123"
  skip_final_snapshot       = true
  cluster_subnet_group_name = var.test_name
  publicly_accessible       = false

  logging {
    bucket_name   = module.aws_logs.aws_logs_bucket
    s3_key_prefix = var.redshift_logs_prefix
    enable        = true
  }

  depends_on = [aws_redshift_subnet_group.test_redshift]
}

resource "aws_redshift_subnet_group" "test_redshift" {
  name       = var.test_name
  subnet_ids = module.vpc.private_subnets
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 2"
  name            = var.test_name
  cidr            = "10.0.0.0/16"
  azs             = var.vpc_azs
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
