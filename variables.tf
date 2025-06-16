variable "ami_id" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "destination_account_id" {}
variable "destination_access_key" {}
variable "destination_secret_key" {}
variable "instance_type" {
  default = "t2.medium"
}
variable "key_name" {
  default = "newacc"
}
variable "instance_name" {
  default = "MyRecreatedEC2"
}


# For S3
variable "s3_bucket_name" {}
variable "s3_bucket_prefix" {}

# For RDS
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "allocated_storage" {
  default = 20
}
variable "db_instance_class" {
  default = "db.t3.micro"
}
