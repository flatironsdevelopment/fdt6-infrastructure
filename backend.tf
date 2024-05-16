terraform {
  backend "s3" {
    bucket = "fdt6-infrastructure-tf"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}