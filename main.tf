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


output "public_ip" {
  value = aws_eip.ip-oms.public_ip
}

output "private_ip" {
  value = aws_instance.oms.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.oms-db.endpoint
}
