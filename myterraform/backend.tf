terraform {
  backend "s3" {
    bucket  = "rctf-state-bucket"
    key     = "state-files/terraform.tfstate"
    region  = "us-west-1"
    profile = "tfuser"
  }
}