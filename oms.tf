resource "aws_instance" "oms" {
  ami = data.aws_ami.redhat-linux-8.id
  instance_type = "t2.micro"
  private_ip = "10.0.1.12"

  key_name = aws_key_pair.oms-ssh.key_name

  security_groups = [ aws_security_group.oms-sg.id ]
  subnet_id = aws_subnet.oms-subnet.id

  tags = {
    Name = data.aws_ami.redhat-linux-8.name
  }

}

resource "null_resource" "ansible" {
  provisioner "remote-exec" {
    inline = ["echo 'Definitely connected!'"]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.oms-ssh.private_key_pem
      host = aws_eip.ip-oms.public_ip
    }
  }

  provisioner "local-exec" {
    command = "awk 'NR == 5 {gsub(\"\\\\S+\",\"${aws_eip.ip-oms.public_ip}:\")}; {print}' ansible/hosts.yaml > ansible/hosts.yaml.new && mv ansible/hosts.yaml.new ansible/hosts.yaml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/playbook.yaml -i ./ansible/hosts.yaml --ssh-common-args='-o StrictHostKeyChecking=no' -e 'db_url=${aws_db_instance.oms-db.address} db_pass=${random_password.rds-password.result}'"
  }

  depends_on = [ aws_instance.oms, aws_db_instance.oms-db ]
}
