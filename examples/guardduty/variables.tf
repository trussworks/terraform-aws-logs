variable "test_name" {
  type = string
}

variable "region" {
  type = string
}

variable "force_destroy" {
  type = bool
}

variable "guardduty_logs_prefixes" {
  type = list(string)
}
