resource "aws_instance" "basic-app" {
  ami           = "ami-09ba19d0563c3d553"
  instance_type = "t2.micro"

  tags = {
    Name = "basic-app-instance"
  }
}
