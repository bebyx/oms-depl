resource "aws_subnet" "oms-subnet" {
  cidr_block = "10.0.1.0/24"
  //cidrsubnet(aws_vpc.oms-vpc.cidr_block, 3, 1)
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

//RDS
resource "aws_subnet" "rds-subnet1" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.oms-vpc.id
  availability_zone = "${var.region}a"
}
resource "aws_subnet" "rds-subnet2" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.oms-vpc.id
  availability_zone = "${var.region}b"
}


resource "aws_db_subnet_group" "default" {
  name = "main"
  subnet_ids = [ aws_subnet.rds-subnet1.id, aws_subnet.rds-subnet2.id ]
}
