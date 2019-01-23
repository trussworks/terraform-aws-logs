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

variable "s3_log_bucket_retention" {
  description = "Number of days to keep AWS logs around."
  default     = 90
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

# Service Switches
variable "default_enable" {
  description = "Create one bucket with all services as bucket keys."
  default     = true
  type        = "string"
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail to log to the AWS logs bucket or the cloudtrail logs bucket."
  default     = false
  type        = "string"
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch to log to the AWS logs bucket or the cloudwatch logs bucket."
  default     = false
  type        = "string"
}

variable "enable_alb" {
  description = "Create one bucket with ALB service as the bucket key."
  default     = false
  type        = "string"
}

variable "enable_config" {
  description = "Create one bucket with Config service as the bucket key."
  default     = false
  type        = "string"
}

variable "enable_elb" {
  description = "Create one bucket with ELB service as the bucket key."
  default     = false
  type        = "string"
}

variable "enable_redshift" {
  description = "Create one bucket with Redshift service as the bucket key."
  default     = false
  type        = "string"
}

variable "enable_s3" {
  description = "Create one bucket with S3 service as the bucket key."
  default     = false
  type        = "string"
}
