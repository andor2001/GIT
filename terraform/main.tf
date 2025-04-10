terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2" # London
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

