resource "aws_ecr_repository" "docker-registry" {
  name = "docker-images"

  image_scanning_configuration {
    scan_on_push = true
  }
}
