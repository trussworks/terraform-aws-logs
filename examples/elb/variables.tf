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

variable "elb_logs_prefix" {
  type = string
}
