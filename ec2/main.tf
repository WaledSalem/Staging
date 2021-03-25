

resource "aws_instance" "public_instance" {
   ami                         = "ami-08962a4068733a2b6"
   instance_type               = "t2.medium"
    key_name = "Karolina"//your key
   subnet_id                   = "${var.public_subnet_id}"
  network_interface {
    device_index         = 0
    network_interface_id = var.net_id
  }
         

 tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "private_instance" {
   ami                         = "ami-08962a4068733a2b6"
   instance_type               = "t2.medium"
    key_name = "Karolina"//your key
   subnet_id                   = "${var.private_subnet_id}"
  network_interface {
    network_interface_id = var.net_id
    device_index = 0
  }

 tags = {
    Name = "KubeControl"
 }
}