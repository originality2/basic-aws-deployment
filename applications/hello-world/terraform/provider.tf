terraform{
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
      region  = "ap-southeast-2" 
      alias   = "regional"
    }
  }

  backend "s3" {
    bucket = "hello-world-backend"
    key    = "state.tfstate"
    region = "ap-southeast-2"
  }
}
