provider "aws" {
  alias      = "source"
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias      = "destination"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_ami_copy" "copied_ami" {
  provider          = aws.destination
  name              = "copied-ami-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  description       = "AMI copied from ap-south-1"
  source_ami_id     = var.ami_id
  source_ami_region = "ap-south-1"
}

resource "time_sleep" "wait_for_ami" {
  depends_on      = [aws_ami_copy.copied_ami]
  create_duration = "200s" # Wait for about 3.3 minutes
}

resource "aws_security_group" "ssh_access" {
  provider    = aws.destination
  name        = "allow-ssh-${random_id.suffix.hex}"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security in production
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
  instance_type               = "t2.micro"
  key_name                    = "newacc"
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  depends_on = [time_sleep.wait_for_ami]

    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "This is the same AMI and Your data exists" > /var/www/html/index.html
              EOF

  tags = {
    Name = "MyRecreatedEC2"
  }
}


