provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_security_group" "ssh_access" {
  name        = "allow-ssh-${random_id.suffix.hex}"  # Unique name using random suffix
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
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "newacc"
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  tags = {
    Name = "MyRecreatedEC2"
  }
}
