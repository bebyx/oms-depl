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

resource "tls_private_key" "oms-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key-file" {
 content = tls_private_key.oms-ssh.private_key_pem
 filename = "${aws_key_pair.oms-ssh.key_name}.pem"
 file_permission = 0400
}

resource "aws_key_pair" "oms-ssh" {
  key_name = "terraform"
  public_key = tls_private_key.oms-ssh.public_key_openssh
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


output "ip-jenkins" {
  value = aws_eip.ip-jenkins.public_ip
}

output "ip-oms" {
  value = aws_eip.ip-oms.public_ip
}

output "private-oms" {
  value = aws_instance.oms.private_ip
}

output "db-endpoint" {
  value = aws_db_instance.oms-db.endpoint
}
