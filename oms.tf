resource "aws_instance" "oms" {
  ami           = data.aws_ami.redhat-linux-8.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.oms-ssh.key_name

  security_groups = [ aws_security_group.oms-sg.id ]
  subnet_id = aws_subnet.oms-subnet.id

  tags = {
    Name = data.aws_ami.redhat-linux-8.name
  }

}

resource "null_resource" "provision" {
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host = aws_eip.ip-oms.public_ip
  }

  provisioner "file" {
    source = "./provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "DB_URL=${aws_db_instance.oms-db.address} /tmp/provision.sh"
    ]
  }

  depends_on = [ aws_db_instance.oms-db ]

}
