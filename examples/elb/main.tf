module "aws_logs" {
  source         = "../../"
  s3_bucket_name = var.logs_bucket
  region         = var.region
  allow_elb      = "true"
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

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "~> 2"
  name           = var.vpc_name
  cidr           = "10.0.0.0/16"
  azs            = var.vpc_azs
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}