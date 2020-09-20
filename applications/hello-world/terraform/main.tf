resource "aws_instance" "basic-app" {
  ami           = "ami-09ba19d0563c3d553"
  instance_type = "t2.micro"
  key_name      = var.key_name

  user_data = file("install_docker.sh")

  tags = {
    Name = "${var.app_name}-instance"
  }
}
