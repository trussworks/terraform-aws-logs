module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.logs_bucket
  region         = var.region
  allow_nlb      = "true"
}

resource "aws_lb" "test_lb" {
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = module.aws_logs.aws_logs_bucket
    prefix  = "nlb"
    enabled = true
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