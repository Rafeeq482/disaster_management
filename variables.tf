variable "aws_region" {
  default = "us-east-1"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_key_name" {
  description = "Name of your AWS key pair"
  type        = string
}

variable "rds_instance_type" {
  default = "db.t3.micro"
}

variable "rds_db_name" {
  default = "mydatabase"
}

variable "rds_username" {
  default = "admin"
}

variable "rds_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
