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

resource "aws_instance" "WebSRV-1" {
    ami = "ami-04da26f654d3383cf"
    instance_type = "t2.micro"

    tags = {
      Name = "WebSRV-1"
    }
  
}
