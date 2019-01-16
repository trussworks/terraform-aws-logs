variable "cloudtrail_cloudwatch_logs_group" {
  description = "The name of the CloudWatch Logs group to send CloudTrail events."
  default     = "cloudtrail-events"
  type        = "string"
}

variable "s3_bucket_name" {
  description = "S3 bucket to store AWS logs in."
  type        = "string"
}

variable "region" {
  description = "Region where the AWS S3 bucket will be created."
  type        = "string"
}

variable "expiration" {
  description = "Number of days to keep AWS logs around."
  default     = 90
  type        = "string"
}

variable "cloudwatch_log_group_retention" {
  description = "Number of days to keep AWS logs around in specific log group."
  default     = 90
  type        = "string"
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail to log to the AWS logs bucket."
  default     = true
  type        = "string"
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  default     = "elb"
  type        = "string"
}

variable "alb_logs_prefix" {
  description = "S3 prefix for ALB logs."
  default     = "alb"
  type        = "string"
}

variable "cloudwatch_logs_prefix" {
  description = "S3 prefix for CloudWatch log exports."
  default     = "cloudwatch"
  type        = "string"
}

variable "cloudtrail_logs_prefix" {
  description = "S3 prefix for CloudTrail logs."
  default     = "cloudtrail"
  type        = "string"
}

variable "redshift_logs_prefix" {
  description = "S3 prefix for RedShift logs."
  default     = "redshift"
  type        = "string"
}

variable "config_logs_prefix" {
  description = "S3 prefix for AWS Config logs."
  default     = "config"
  type        = "string"
}
