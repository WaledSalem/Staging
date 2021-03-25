variable "access_key" {
}
variable "secret_key" {
}
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  version = "~> 2.0"
  region = "eu-west-1"
}
resource "aws_vpc" "main" {
  cidr_block          = "10.0.0.0/16"  
  instance_tenancy    = "default"  
  tags = {
     Name = "jenkins-resources-vnet"
   }
}

##============================================
 #create subnet ##resource 3##
 
resource "aws_subnet" "internal" {
  vpc_id               = aws_vpc.main.id
  cidr_block           = "10.0.1.0/24"
  tags = {
    Name = "jenkins-internal"
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
##============================================
#create public IP ##resource 4##



##============================================


##============================================
##resource 6##

resource "aws_security_group" "jenkins" {

  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.internal.id
  route_table_id = aws_route_table.prod-route-table.id
}
resource "aws_eip" "main" {
   network_interface = aws_network_interface.main.id
   associate_with_private_ip = "10.0.1.50"
   vpc      = true
   depends_on = [aws_internet_gateway.gw]
 }

 resource "aws_network_interface" "main" {
   subnet_id       = aws_subnet.internal.id
   private_ips     = ["10.0.1.50"]//any id whithin the subnet ip
   security_groups = [aws_security_group.jenkins.id]
   tags = {
     Name = "kube_network_interface"
   }
}
##============================================
#Create VM ##resource 7##
resource "aws_instance" "main" {
  ami           = "ami-096cb92bb3580c759"
  instance_type = "t2.medium"
    key_name = "project"//your key
  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index = 0
  #vpc_security_group_ids = [aws_security_group.main.id]
  }
    tags = {
    Name = "jenkins"
  }
}

#========================================
##??##

##??##
