#configure aws provider 
#set access_key and secret_key later
provider "aws"{
    access_key = ""
    secret_key = ""
    region = "eu-west-2"
}

#create resource group
resource "aws_resourcegroups_group" "main" {
    name = "kube-controller"
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
  cidr_block= "10.0.2.0/24"
  //availability_zone = "eu-west-2a"//need? 
  tags = {
     Name = "internal"
  }
 }

//need to look here again------------------
#public ip
resource "aws_eip" "main" {
  network_interface = aws_network_interface.main.id
  //associate_with_private_ip = "10.0.1.50"
  vpc      = true
  depends_on = [aws_internet_gateway.gw]
}
#network interface
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["10.0.1.50"]//any id whithin the subnet ip
  security_groups = [aws_security_group.allow_web.id]
}