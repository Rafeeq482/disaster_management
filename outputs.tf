output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}
