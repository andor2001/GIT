variable "ami_id" {
    type = string
    description = "The id of the machine image (AMI) to use for the server"
    default = "ami-04da26f654d3383cf"
}

variable "inst_type" {
  type = string
  description = "This is instance type for the server"
  default = "t2.micro"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical  
}
