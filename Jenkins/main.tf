provider "aws" {
  region = "eu-west-1"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#create resource group  ##resource 1##
resource "aws_resourcegroups_group" "main" {
  name     = "jenkins-resources"
  #location = "eu-west-2a" 
    resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "Stage",
      "Values": ["Test"]
    }
  ]
}
JSON
  }
}
 ##============================================

resource "aws_vpc" "main" {
  cidr_block          = "10.0.0.0/16"  
  instance_tenancy    = "default"  
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


 ##============================================
 #create public IP ##resource 4##

resource "aws_eip" "main" {
  instance            = aws_instance.main.id
  vpc                 = true
}


 ##============================================
#create NIC ##resource 5##
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["10.0.1.10"] #["10.0.0.50"]
  security_groups = [aws_security_group.main.id]

 }


##============================================

##resource 6##

resource "aws_security_group" "main" {

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
}

##============================================
  #Create VM ##resource 7##
resource "aws_instance" "main" {
  ami           = "ami-02df9ea15c1778c9c"
  instance_type = "t2.micro"
  #vpc_security_group_ids = [aws_security_group.main.id]
  }


  #========================================
  ##??##

##??##
