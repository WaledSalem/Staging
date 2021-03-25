

provider "aws"{
    access_key = var.access_key
    secret_key = var.secret_key
    region = "us-west-2"
}


resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

}


#internet gate way
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.main_vpc.id
}

#aws_route_table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.main_vpc.id

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
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    description= "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
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

