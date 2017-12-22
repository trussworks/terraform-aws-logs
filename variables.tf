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
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  default     = "elb"
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
