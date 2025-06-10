terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

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
  