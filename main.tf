provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  tags = {
    Name = "MyRecreatedEC2"
  }
}
