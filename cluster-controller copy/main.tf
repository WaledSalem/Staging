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
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block= "10.0.2.0/24"
  tags = {
     Name = "internal"
  }
 }

//need to look here again------------------
#public ip
resource "aws_subnet" "private_subnet" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "external"
  }
}

