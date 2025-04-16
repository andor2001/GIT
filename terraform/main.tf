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

#################################################################################
# create vpc for web_srv
resource "aws_vpc" "vpc_web_srv" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "WEBSRV-1"
  }
}

# create subnet for public network
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc_web_srv.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-Net"
  }
}

## create subnet for private network
# resource "aws_subnet" "private" {
#   vpc_id = aws_instance.web.id
#   cidr_block = "10.0.2.0/24"

#   tags = {
#     Name = "Private-Net"
#   }
# }

# create internet gateway
resource "aws_internet_gateway" "ig_web_srv" {
  vpc_id = aws_vpc.vpc_web_srv.id

  tags = {
    Name = "IG_WebSRV-1"
  }
}

# create route via internet gateway
resource "aws_route_table" "rt_ig" {
  vpc_id = aws_vpc.vpc_web_srv.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_web_srv.id
  }

  tags = {
    Name = "WebSRV_RT_Public"
  }
}

# association route table to private net
resource "aws_route_table_association" "asoc_priv_net" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.rt_ig.id
}

# create security group 
resource "aws_security_group" "sg_web_srv" {
  name = "ssh_web"
  description = "Allow 22 and 80 ports traffic"
  vpc_id = aws_vpc.vpc_web_srv.id
  
  # allow ssh input traffic from all ip address
  ingress {
    description = "SSH from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow http input traffic from all ip address
  ingress {
    description = "WEB form VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # output traffic all ports and all ip address
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-web-sg"
  }
}

# create instance
resource "aws_instance" "web" {  
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg_web_srv.id]
  associate_public_ip_address = true
  key_name = "andor2001@ukr.net"


  tags = {
    Name = "Hello web!"

# update apt repository & upgrade system & install nginx
  user_data = <<EOF
   #!/bin/bash
   apt update
   apt upgrade -y
   apt install nginx -y
   EOF
  }
}
# get instance public ip address
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

