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

# create instance Web sever 1
resource "aws_instance" "WebSRV-1" {
    ami = var.ami_id
    instance_type = "t2.micro"

    tags = {
      Name = "WebSRV-1"
    }
  
}
