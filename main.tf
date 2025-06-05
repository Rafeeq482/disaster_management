# =====================
# 0. Default AWS Provider (required)
# =====================

provider "aws" {
  region = "ap-south-1"  # Default region; can be overridden if needed
}

# =====================
# 1. Providers
# =====================

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

# =====================
# 2. Random Suffix for unique naming
# =====================

resource "random_id" "suffix" {
  byte_length = 4
}

# =====================
# 3. Fetch AMI Info by Filtering image-id (correct way)
# =====================

data "aws_ami" "source_ami" {
  provider = aws.source

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }

  owners = ["self"]  # Or the source account ID if needed
}

# =====================
# 4. Share AMI Launch Permission with destination account
# =====================

resource "aws_ami_launch_permission" "share_to_destination" {
  provider   = aws.source
  image_id   = var.ami_id
  account_id = var.destination_account_id
}

# Note: 
# There is NO Terraform resource for sharing EBS snapshot permissions.
# Sharing the AMI launch permission automatically shares snapshot permissions for snapshots owned by the AMI owner.

# =====================
# 5. Copy AMI into Destination Account
# =====================

resource "aws_ami_copy" "copied_ami" {
  provider          = aws.destination
  name              = "copied-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  description       = "AMI copied from ap-south-1"
  source_ami_id     = var.ami_id
  source_ami_region = "ap-south-1"

  depends_on = [aws_ami_launch_permission.share_to_destination]
}

# =====================
# 6. Wait for AMI to be Available before launching EC2
# =====================

resource "time_sleep" "wait_for_ami" {
  depends_on      = [aws_ami_copy.copied_ami]
  create_duration = "200s"  # Adjust time as needed
}

# =====================
# 7. Security Group in Destination Account
# =====================

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

# =====================
# 8. Launch EC2 Instance in Destination Account
# =====================

resource "aws_instance" "web_server" {
  provider                    = aws.destination
  ami                         = aws_ami_copy.copied_ami.id
  instance_type               = "t3.micro"
  key_name                    = "newacc"  # Make sure this key exists in destination account/region
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  depends_on = [time_sleep.wait_for_ami]

  tags = {
    Name = "MyRecreatedEC2"
  }
}
