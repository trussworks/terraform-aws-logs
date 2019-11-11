module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.logs_bucket
  region         = var.region
}

resource "aws_lb" "test_alb" {
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = module.aws_logs.aws_logs_bucket
    prefix  = "alb"
    enabled = true
  }
}

module "aws_cloudtrail" {
  source         = "trussworks/cloudtrail/aws"
  version        = "~> 2"
  s3_bucket_name = module.aws_logs.aws_logs_bucket
}

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 2"

  config_logs_bucket = module.aws_logs.aws_logs_bucket
  config_logs_prefix = "config"
}

resource "aws_elb" "test_elb" {
  subnets = module.vpc.public_subnets

  access_logs {
    bucket        = module.aws_logs.aws_logs_bucket
    bucket_prefix = "elb"
    enabled       = true
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_lb" "test_nlb" {
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = module.aws_logs.aws_logs_bucket
    prefix  = "nlb"
    enabled = true
  }
}

resource "aws_redshift_cluster" "test_redshift" {
  count               = var.test_redshift ? 1 : 0
  cluster_identifier  = "tf-redshift-cluster"
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

resource "aws_s3_bucket" "log_source_bucket" {
  acl = "private"

  logging {
    target_bucket = module.aws_logs.aws_logs_bucket
    target_prefix = "log/"
  }
}

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "~> 2"
  name           = var.vpc_name
  cidr           = "10.0.0.0/16"
  azs            = var.vpc_azs
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
