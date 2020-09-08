variable "test_name" {
  type = string
}

variable "force_destroy" {
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}
