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


#internet gate way
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.main.id
}

#aws_route_table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Prod"
  }
}

resource "aws_security_group" "allow_web" {
  name = "allow_web_traffic"
  description = "Allow web inbound trafiic"
  vpc_id = aws_vpc.main.id

  ingress{
    description= "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]// change to anyone to access
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow web"
  }
}

#allow route table association
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.internal.id
  route_table_id = aws_route_table.prod-route-table.id
}
 #public ip
resource "aws_eip" "main" {
   network_interface = aws_network_interface.main.id
   associate_with_private_ip = "10.0.1.50"
   vpc      = true
   depends_on = [aws_internet_gateway.gw]
 }
#network interface
resource "aws_network_interface" "main" {
   subnet_id       = aws_subnet.internal.id
   private_ips     = ["10.0.1.50"]//any id whithin the subnet ip
   security_groups = [aws_security_group.allow_web.id]
   tags = {
     Name = "kube_network_interface"
   }
}
//---------------

#create VM
resource "aws_instance" "main" {
  ami = "ami-096cb92bb3580c759"
  instance_type= "t2.medium"
  key_name = "serin"//your key
  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index = 0
  }
  tags = {
    Name = "kube-vm"
  }
}
