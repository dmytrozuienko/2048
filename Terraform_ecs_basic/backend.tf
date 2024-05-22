terraform {
  backend "s3" {
    key = "terraform/tfstate.tfstate"
    bucket = "app2048-terraform-tfstate"
    region = "us-east-1"
  }
}