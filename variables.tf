variable "s3_bucket_name" {
  description = "S3 bucket to store AWS logs in."
  type        = string
}

variable "s3_log_bucket_retention" {
  description = "Number of days to keep AWS logs around."
  default     = 90
  type        = string
}

variable "noncurrent_version_retention" {
  description = "Number of days to retain non-current versions of objects if versioning is enabled."
  type        = string
  default     = 30
}

variable "s3_bucket_acl" {
  description = "Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list."
  default     = "log-delivery-write"
  type        = string
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  default     = "elb"
  type        = string
}

variable "alb_logs_prefixes" {
  description = "S3 key prefixes for ALB logs."
  default     = ["alb"]
  type        = list(string)
}

variable "cloudwatch_logs_prefix" {
  description = "S3 prefix for CloudWatch log exports."
  default     = "cloudwatch"
  type        = string
}

variable "cloudtrail_logs_prefix" {
  description = "S3 prefix for CloudTrail logs."
  default     = "cloudtrail"
  type        = string
}

variable "redshift_logs_prefix" {
  description = "S3 prefix for RedShift logs."
  default     = "redshift"
  type        = string
}

variable "config_logs_prefix" {
  description = "S3 prefix for AWS Config logs."
  default     = "config"
  type        = string
}

# Service Switches
variable "default_allow" {
  description = "Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write."
  default     = true
  type        = bool
}

variable "allow_cloudtrail" {
  description = "Allow Cloudtrail service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_cloudwatch" {
  description = "Allow Cloudwatch service to export logs to bucket."
  default     = false
  type        = bool
}

variable "allow_alb" {
  description = "Allow ALB service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_nlb" {
  description = "Allow NLB service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_config" {
  description = "Allow Config service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_elb" {
  description = "Allow ELB service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_redshift" {
  description = "Allow Redshift service to log to bucket."
  default     = false
  type        = bool
}

variable "create_public_access_block" {
  description = "Whether to create a public_access_block restricting public access to the bucket."
  default     = true
  type        = bool
}

variable "cloudtrail_accounts" {
  description = "List of accounts for CloudTrail logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "config_source_accounts" {
  description = "List of source accounts with permission to send logs Config bucket."
  default     = []
  type        = list(string)
}

variable "config_accounts" {
  description = "List of accounts for Config logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "alb_account" {
  description = "Account for ALB logs.  By default limits to the current account."
  default     = ""
  type        = string
}

variable "elb_accounts" {
  description = "List of accounts for ELB logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "nlb_account" {
  description = "Account for NLB logs.  By default limits to the current account."
  default     = ""
  type        = string
}

variable "force_destroy" {
  description = "A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error."
  default     = false
  type        = bool
}

variable "nlb_logs_prefixes" {
  description = "S3 key prefixes for NLB logs."
  default     = ["nlb"]
  type        = list(string)
}

variable "cloudtrail_org_id" {
  description = "AWS Organization ID for CloudTrail."
  default     = ""
  type        = string
}

variable "logging_target_bucket" {
  description = "S3 Bucket to send S3 logs to. Disables logging if omitted."
  default     = null
  type        = string
}

variable "logging_target_prefix" {
  description = "Prefix for logs going into the log_s3_bucket."
  default     = "s3/"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the logs bucket. Please note that tags with a conflicting key will not override the original tag."
}

variable "enable_versioning" {
  description = "A bool that enables versioning for the log bucket."
  default     = false
  type        = bool
}

variable "enable_mfa_delete" {
  description = "A bool that requires MFA to delete the log bucket."
  default     = false
  type        = bool
}
