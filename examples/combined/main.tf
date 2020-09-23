module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name
  default_allow  = true

  force_destroy = var.force_destroy
}

resource "aws_lb" "test_alb" {
  name               = var.test_name
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
  source  = "trussworks/cloudtrail/aws"
  version = "~> 2"

  s3_bucket_name            = module.aws_logs.aws_logs_bucket
  s3_key_prefix             = "cloudtrail"
  cloudwatch_log_group_name = var.test_name
}

module "config" {
  source  = "trussworks/config/aws"
  version = "~> 3"

  config_name        = var.test_name
  config_logs_bucket = module.aws_logs.aws_logs_bucket
  config_logs_prefix = "config"
}

resource "aws_elb" "test_elb" {
  name    = var.test_name
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
  name               = var.test_name
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
  count = var.test_redshift ? 1 : 0

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
    s3_key_prefix = "redshift"
    enable        = true
  }

  depends_on = [aws_redshift_subnet_group.test_redshift]
}

resource "aws_redshift_subnet_group" "test_redshift" {
  count = var.test_redshift ? 1 : 0

  name       = var.test_name
  subnet_ids = module.vpc.private_subnets
}

resource "aws_s3_bucket" "log_source_bucket" {
  bucket        = "${var.test_name}-source"
  acl           = "private"
  force_destroy = var.force_destroy

  logging {
    target_bucket = module.aws_logs.aws_logs_bucket
    target_prefix = "log/"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name            = var.test_name
  cidr            = "10.0.0.0/16"
  azs             = var.vpc_azs
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
