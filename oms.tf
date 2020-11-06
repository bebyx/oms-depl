terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region  = var.region
}

resource "aws_key_pair" "oms-ssh" {
  key_name = "terraform"
  public_key = file("~/.ssh/terraform.pub")
}


data "aws_ami" "redhat-linux-8" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-8.*"]
  }

  filter {
   name   = "virtualization-type"
   values = ["hvm"]
  }

  filter {
   name   = "architecture"
   values = ["x86_64"]
 }
}

resource "aws_instance" "oms" {
  ami           = data.aws_ami.redhat-linux-8.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.oms-ssh.key_name

  security_groups = [ aws_security_group.ingress-all-oms.id ]
  subnet_id = aws_subnet.oms-subnet.id

  tags = {
    Name = data.aws_ami.redhat-linux-8.name
  }

}

output "public_ip" {
  value = aws_eip.ip-oms.public_ip
}

output "private_ip" {
  value = aws_instance.oms.private_ip
}
