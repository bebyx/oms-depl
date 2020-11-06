resource "aws_internet_gateway" "oms-gw" {
  vpc_id = aws_vpc.oms-vpc.id

  tags = {
    Name = "oms-gw"
  }
}
