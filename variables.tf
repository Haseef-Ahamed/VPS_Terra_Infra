variable "env" {
  type    = string
  default = "dev"
}

variable "app_count" {
  type    = number
  default = 2
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "mydb"
}