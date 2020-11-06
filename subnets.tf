resource "aws_subnet" "oms-subnet" {
  cidr_block = cidrsubnet(aws_vpc.oms-vpc.cidr_block, 3, 1)
  vpc_id = aws_vpc.oms-vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "oms-subnet"
  }
}

resource "aws_route_table" "route-table-oms" {
  vpc_id = aws_vpc.oms-vpc.id

  tags = {
    Name = "oms-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oms-gw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id = aws_subnet.oms-subnet.id
  route_table_id = aws_route_table.route-table-oms.id
}
