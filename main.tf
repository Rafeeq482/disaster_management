provider "aws" {
  region = var.aws_region
}

# 🔍 Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 💻 EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  tags = {
    Name = "MyEC2Instance"
  }
}

# 🛢️ RDS Instance (MySQL)
resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.rds_instance_type
  db_name              = var.rds_db_name
  username             = var.rds_username
  password             = var.rds_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  publicly_accessible = true

  tags = {
    Name = "MyRDSInstance"
  }
}
