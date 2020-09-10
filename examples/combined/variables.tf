variable "test_name" {
  type = string
}

variable "config_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "test_redshift" {
  type    = bool
  default = true
}

variable "force_destroy" {
  type = bool
}

variable "config_logs_bucket" {
  type = string
}
