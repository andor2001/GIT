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

# # create instance Web sever 1
# resource "aws_instance" "WebSRV-1" {
#     ami = var.ami_id
#     instance_type = var.inst_type
    
#     tags = {
#       Name = "WebSRV-1"
#     }
  
# }

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "Hello web!"
  }
}