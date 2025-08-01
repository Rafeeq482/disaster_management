resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-${random_id.suffix.hex}"

  tags = {
    Name = var.bucket_name
  }
}
