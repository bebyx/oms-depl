resource "aws_vpc" "oms-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "oms-vpc"
  }
}

resource "aws_eip" "ip-oms" {
  vpc      = true
  instance = aws_instance.oms.id
  associate_with_private_ip = "10.0.1.12"
}

resource "aws_eip" "ip-jenkins" {
  vpc      = true
  instance = aws_instance.jenkins.id
  associate_with_private_ip = "10.0.1.13"
}
