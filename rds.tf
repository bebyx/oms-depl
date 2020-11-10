resource "aws_db_instance" "oms-db" {
  allocated_storage = 100
  storage_type = "gp2"
  engine = "mariadb"
  instance_class = "db.t2.micro"
  identifier = "omsdb"
  username = "oms"
  password = "password"
  multi_az = false
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.oms-db.id
  vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
  parameter_group_name = aws_db_parameter_group.oms-db.id
}

resource "aws_db_parameter_group" "oms-db" {
  name   = "rds-pg"
  family = "mariadb10.4"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
