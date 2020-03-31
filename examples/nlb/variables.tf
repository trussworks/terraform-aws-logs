variable "test_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "force_destroy" {
  type = bool
}

variable "nlb_logs_prefixes" {
  type = list(string)
}
