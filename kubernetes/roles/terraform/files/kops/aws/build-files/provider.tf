provider "aws" {
  version = "~> v2.33.0"
  region = var.region
}

data "aws_region" "current" {}