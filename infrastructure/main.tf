resource "aws_instance" "basic-app" {
  ami           = "ami-09ba19d0563c3d553"
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "basic-app-instance"
  }
}
