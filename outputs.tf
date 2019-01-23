output "aws_logs_bucket" {
  description = "S3 bucket containing AWS logs."
  value       = "${aws_s3_bucket.aws_logs.id}"
}

# output "cloudtrail_cloudwatch_logs_arn" {
#   description = "The ARN of the CloudWatch Logs group storing CloudTrail Events."
#   value       = "${aws_cloudwatch_log_group.main.*.arn}"
# }

# output "cloudtrail_logs_path" {
#   description = "S3 path for CloudTrail logs."
#   value       = "${var.cloudtrail_logs_prefix}"
# }

output "configs_logs_path" {
  description = "S3 path for Config logs."
  value       = "${var.config_logs_prefix}"
}

output "elb_logs_path" {
  description = "S3 path for ELB logs."
  value       = "${var.elb_logs_prefix}"
}

output "redshift_logs_path" {
  description = "S3 path for RedShift logs."
  value       = "${var.redshift_logs_prefix}"
}
