resource "aws_instance" "jenkins" {
  ami = data.aws_ami.redhat-linux-8.id
  instance_type = "t2.micro"
  private_ip = "10.0.1.13"

  key_name = aws_key_pair.oms-ssh.key_name

  security_groups = [ aws_security_group.oms-sg.id ]
  subnet_id = aws_subnet.oms-subnet.id

  tags = {
    Name = "jenkins"
  }

}

resource "null_resource" "jenkins" {
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = tls_private_key.oms-ssh.private_key_pem
    host = aws_eip.ip-jenkins.public_ip
  }

  provisioner "file" {
    source = "./terraform.pem"
    destination = "/tmp/terraform.pem"
  }

  provisioner "file" {
    source = "./jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins.sh",
      "/tmp/jenkins.sh"
    ]
  }

  depends_on = [ aws_instance.jenkins, null_resource.provision,
                 aws_db_instance.oms-db, local_file.key-file ]

}
