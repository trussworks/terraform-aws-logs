module "aws_logs" {
  source = "../../"

  s3_bucket_name = var.test_name

  force_destroy = var.force_destroy
  tags          = var.tags
}

data "aws_iam_policy_document" "updated_logs_bucket_policy" {
  source_policy_documents = [module.aws_logs.s3_bucket_policy.json]
  statement {
    sid     = "Allow vpc endpoint"
    actions = ["s3:*"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = ["vpce-0123567"]
    }

    resources = [
      module.aws_logs.bucket_arn,
      "${module.aws_logs.bucket_arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

}
resource "aws_s3_bucket_policy" "logs_updated_bucket_policy" {
  bucket = module.logs.aws_logs_bucket
  policy = data.updated_logs_bucket_policy.json
}
