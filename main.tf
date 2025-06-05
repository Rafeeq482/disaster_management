# Source Account A Provider
provider "aws" {
  alias      = "source"
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Destination Account B Provider
provider "aws" {
  alias      = "destination"
  region     = "ap-south-2"
  access_key = var.destination_access_key
  secret_key = var.destination_secret_key
}

# Generate random suffix for uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# Share AMI from Account A to Account B
resource "aws_ami_launch_permission" "share_to_destination" {
  provider   = aws.source
  image_id   = var.ami_id
  account_id = var.destination_account_id
}

# Copy the shared AMI into destination account
resource "aws_ami_copy" "copied_ami" {
  provider          = aws.destination
  name              = "copied-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  description       = "AMI copied from ap-south-1"
  source_ami_id     = var.ami_id
  source_ami_region = "ap-south-1"  # ✅ fixed: must match the region of the source AMI

  depends_on = [aws_ami_launch_permission.share_to_destination]
}

# Sleep to wait for AMI to be fully available
resource "time_sleep" "wait_for_ami" {
  depends_on      = [aws_ami_copy.copied_ami]
  create_duration = "200s"
}

# Security group in destination account
resource "aws_security_group" "ssh_access" {
  provider    = aws.destination
  name        = "allow-ssh-${random_id.suffix.hex}"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
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

# Launch EC2 in destination account using copied AMI
resource "aws_instance" "web_server" {
  provider                    = aws.destination
  ami                         = aws_ami_copy.copied_ami.id
  instance_type               = "t3.micro"
  key_name                    = "newacc"  # ✅ Make sure this key exists in destination account!
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true
  depends_on                  = [time_sleep.wait_for_ami]

  tags = {
    Name = "MyRecreatedEC2"
  }
}
