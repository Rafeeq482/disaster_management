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
