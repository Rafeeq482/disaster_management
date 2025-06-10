terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  alias      = "source"
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias      = "destination"
  region     = "ap-south-1"
  access_key = var.destination_access_key
  secret_key = var.destination_secret_key
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "aws_ami" "source_ami" {
  provider = aws.source

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }

  owners = ["self"]
}

resource "aws_ami_launch_permission" "share_to_destination" {
  provider   = aws.source
  image_id   = var.ami_id
  account_id = var.destination_account_id
}

resource "aws_snapshot_create_volume_permission" "share_snapshot" {
  provider    = aws.source
  snapshot_id = tolist(data.aws_ami.source_ami.block_device_mappings)[0].ebs.snapshot_id
  account_id  = var.destination_account_id

  depends_on = [aws_ami_launch_permission.share_to_destination]
}

resource "aws_ami_copy" "copied_ami" {
  provider          = aws.destination
  name              = "copied-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  description       = "AMI copied from ap-south-1"
  source_ami_id     = var.ami_id
  source_ami_region = "ap-south-1"

  depends_on = [
    aws_ami_launch_permission.share_to_destination,
    aws_snapshot_create_volume_permission.share_snapshot
  ]
}

resource "time_sleep" "wait_for_ami" {
  depends_on      = [aws_ami_copy.copied_ami]
  create_duration = "200s"
}

resource "aws_security_group" "ssh_access" {
  provider    = aws.destination
  name        = "allow-ssh-${random_id.suffix.hex}"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  provider                    = aws.destination
  ami                         = aws_ami_copy.copied_ami.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  depends_on = [time_sleep.wait_for_ami]

  tags = {
    Name = var.instance_name
  }
}
