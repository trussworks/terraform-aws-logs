variable "test_name" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "force_destroy" {
  type = bool
}

variable "redshift_logs_prefix" {
  type = string
}
