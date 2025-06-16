module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_id                  = var.ami_id
  aws_access_key          = var.aws_access_key
  aws_secret_key          = var.aws_secret_key
  destination_account_id  = var.destination_account_id
  destination_access_key  = var.destination_access_key
  destination_secret_key  = var.destination_secret_key
  key_name                = var.key_name
  instance_type           = var.instance_type
  instance_name           = var.instance_name
}

module "s3_bucket" {
  source       = "./modules/s3_bucket"
  bucket_name  = var.s3_bucket_name
  bucket_prefix = var.s3_bucket_prefix
}

module "rds_instance" {
  source            = "./modules/rds_instance"
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  allocated_storage = var.allocated_storage
  instance_class    = var.db_instance_class
}
