variable "access_key" {

}
variable "secret_key" {
  
}

#configure aws provider 
#set access_key and secret_key later
provider "aws"{
    access_key = var.access_key
    secret_key = var.secret_key
    region = "eu-west-2"
}

#virtual network
resource "aws_vpc" "main"{
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "kube-network"
   }
}

#subnet
resource "aws_subnet" "internal" {
  vpc_id = aws_vpc.main.id
  cidr_block= "10.0.1.0/24"
  tags = {
     Name = "internal"
  }
 }

//need to look here again------------------
#internet gate way
# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.main.id
# }
# #public ip
# resource "aws_eip" "main" {
#   network_interface = aws_network_interface.main.id
#   //associate_with_private_ip = "10.0.1.50"
#   vpc      = true
#   depends_on = [aws_internet_gateway.gw]
# }
#network interface
resource "aws_network_interface" "main" {
   subnet_id       = aws_subnet.internal.id
   private_ips     = ["10.0.1.50"]//any id whithin the subnet ip
   //security_groups = [aws_security_group.allow_web.id]
   tags = {
     Name = "kube_network_interface"
   }
}
//---------------

#create VM
resource "aws_instance" "main" {
  ami = "ami-096cb92bb3580c759"
  instance_type= "t2.micro"
  
  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index = 0
  }
  tags = {
    Name = "kube-vm"
  }
}
