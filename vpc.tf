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
}
