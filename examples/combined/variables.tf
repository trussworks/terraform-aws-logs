variable "logs_bucket" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "test_redshift" {
  type    = bool
  default = true
}
