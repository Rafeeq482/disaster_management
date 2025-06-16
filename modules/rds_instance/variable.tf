variable "allocated_storage" {
  default = 20
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {}
variable "username" {}
variable "password" {}
