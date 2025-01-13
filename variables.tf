variable "alb_account" {
  description = "Account for ALB logs.  By default limits to the current account."
  default     = ""
  type        = string
}

variable "alb_logs_prefixes" {
  description = "S3 key prefixes for ALB logs."
  default     = ["alb"]
  type        = list(string)
}

variable "allow_alb" {
  description = "Allow ALB service to log to bucket."
  default     = false
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

variable "allow_nlb" {
  description = "Allow NLB service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_redshift" {
  description = "Allow Redshift service to log to bucket."
  default     = false
  type        = bool
}

variable "allow_s3" {
  description = "Allow S3 service to log to bucket."
  default     = false
  type        = bool
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "cloudtrail_accounts" {
  description = "List of accounts for CloudTrail logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "cloudtrail_logs_prefix" {
  description = "S3 prefix for CloudTrail logs."
  default     = "cloudtrail"
  type        = string
}

variable "cloudtrail_org_id" {
  description = "AWS Organization ID for CloudTrail."
  default     = ""
  type        = string
}

variable "cloudwatch_logs_prefix" {
  description = "S3 prefix for CloudWatch log exports."
  default     = "cloudwatch"
  type        = string
}

variable "config_accounts" {
  description = "List of accounts for Config logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "config_logs_prefix" {
  description = "S3 prefix for AWS Config logs."
  default     = "config"
  type        = string
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true
}

variable "create_public_access_block" {
  description = "Whether to create a public_access_block restricting public access to the bucket."
  default     = true
  type        = bool
}

variable "default_allow" {
  description = "Whether all services included in this module should be allowed to write to the bucket by default. Alternatively select individual services. It's recommended to use the default bucket ACL of log-delivery-write."
  default     = true
  type        = bool
}

variable "elb_accounts" {
  description = "List of accounts for ELB logs.  By default limits to the current account."
  default     = []
  type        = list(string)
}

variable "elb_logs_prefix" {
  description = "S3 prefix for ELB logs."
  default     = ["elb"]
  type        = list(string)
}

variable "enable_mfa_delete" {
  description = "A bool that requires MFA to delete the log bucket."
  default     = false
  type        = bool
}

variable "enable_s3_log_bucket_lifecycle_rule" {
  description = "Whether the lifecycle rule for the log bucket is enabled."
  default     = true
  type        = bool
}

variable "force_destroy" {
  description = "A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error."
  default     = false
  type        = bool
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. If blank, bucket encryption configuration defaults to AES256."
  type        = string
  default     = ""
}

variable "logging_target_bucket" {
  description = "S3 Bucket to send S3 logs to. Disables logging if omitted."
  default     = ""
  type        = string
}

variable "logging_target_prefix" {
  description = "Prefix for logs going into the log_s3_bucket."
  default     = "s3/"
  type        = string
}

variable "nlb_account" {
  description = "Account for NLB logs.  By default limits to the current account."
  default     = ""
  type        = string
}

variable "nlb_logs_prefixes" {
  description = "S3 key prefixes for NLB logs."
  default     = ["nlb"]
  type        = list(string)
}

variable "noncurrent_version_retention" {
  description = "Number of days to retain non-current versions of objects if versioning is enabled."
  type        = string
  default     = 30
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "redshift_logs_prefix" {
  description = "S3 prefix for RedShift logs."
  default     = "redshift"
  type        = string
}

variable "s3_bucket_acl" {
  description = "Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list."
  default     = null
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket to store AWS logs in."
  type        = string
}

variable "s3_log_bucket_retention" {
  description = "Number of days to keep AWS logs around."
  default     = 90
  type        = string
}

variable "s3_logs_prefix" {
  description = "S3 prefix for S3 access logs."
  default     = "s3"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the logs bucket. Please note that tags with a conflicting key will not override the original tag."
}

variable "versioning_status" {
  description = "A string that indicates the versioning status for the log bucket."
  default     = "Disabled"
  type        = string
  validation {
    condition     = contains(["Enabled", "Disabled", "Suspended"], var.versioning_status)
    error_message = "Valid values for versioning_status are Enabled, Disabled, or Suspended."
  }
}
