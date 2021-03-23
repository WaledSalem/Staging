#create resource group  ##resource 1##
resource "azurerm_resource_group" "main" {
  name     = "jenkins-resources"
  location = "East US 2" 
}

resource "aws_resourcegroups_group" "main" {
  name     = "jenkins-resources"
  location = "eu-west-2a" 
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
 #create virtual network  ##resource 2##
resource "azurerm_virtual_network" "main" {
  name                = "jenkins-resources-vnet" ##keep, or give a new name##
  address_space       = ["10.0.0.0/16"]   #keep##
  location            = azurerm_resource_group.main.location ##the left hand side needs to be changed to the aws resouce 1##
  resource_group_name = azurerm_resource_group.main.name  ## the left hand side needs to be changed to the aws resouce 1##
}

resource "aws_vpc" "main" {
  cidr_block          = "10.0.0.0/16"  
  instance_tenancy    = "default"  
}

 ##============================================
 #create subnet ##resource 3##
resource "azurerm_subnet" "internal" {
  name                 = "jenkins-internal" ##keep, or give a new name##
  resource_group_name  = azurerm_resource_group.main.name ##the left hand side needs to be changed to the aws resouce 1##
  virtual_network_name = azurerm_virtual_network.main.name ##the left hand side needs to be changed to the aws resouce 1##
  address_prefix       = "10.0.3.0/24" #keep##
}

resource "aws_subnet" "internal" {
  vpc_id               = aws_vpc.main.id
  cidr_block           = "10.0.1.0/24"
  tags = {
    Name = "jenkins-internal"
  }
}


 ##============================================
 #create public IP ##resource 4##
resource "azurerm_public_ip" "main" {
  name                = "jenkins-vm-ip" ##keep, or give a new name##
  location            = "East US 2"     ##change to eu-west-1 (check it, make sure the format is correct)## 
  resource_group_name = azurerm_resource_group.main.name  ##the left hand side needs to be changed to the aws resouce 1##
  allocation_method   = "Static "  #keep##

}



resource "aws_eip" "main" {
  instance            = aws_instance.main.id
  vpc                 = true
}


 ##============================================
#create NIC ##resource 5##
resource "azurerm_network_interface" "main" {
  name                = "jenkins-vm-nic" ##keep, or give a new name##  
  location            = azurerm_resource_group.main.location ##the left hand side needs to be changed to the aws resouce 1##
  resource_group_name = azurerm_resource_group.main.name ##the left hand side needs to be changed to the aws resouce 1##

  ip_configuration {
    name                          = "jenkins-ipconfiguration" ##keep, or give a new name##
    subnet_id                     = azurerm_subnet.internal.id ##the left hand side needs to be changed to the aws resouce 3##
    private_ip_address_allocation = "Dynamic" #keep##
    public_ip_address_id          = azurerm_public_ip.main.id ##the left hand side needs to be changed to the aws resouce 4##
  }
}



#create NIC ##resource 5##
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.main.id]

 }


##============================================

##resource 6##
resource "azurerm_network_security_group" "main" {

  name                = "jenkins-vm-nsg" ##keep, or give a new name##  
  location            = azurerm_resource_group.main.location ##the left hand side needs to be changed to the aws resouce 1##
  resource_group_name = azurerm_resource_group.main.name ##the left hand side needs to be changed to the aws resouce 1##

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



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
resource "azurerm_virtual_machine" "main" {
  name                  = "jenkins-vm" ##keep, or give a new name## 
  location              = azurerm_resource_group.main.location ##the left hand side needs to be changed to the aws resouce 1##
  resource_group_name   = azurerm_resource_group.main.name ##the left hand side needs to be changed to the aws resouce 1##
  network_interface_ids = [azurerm_network_interface.main.id] ##the left hand side needs to be changed to the aws resouce 5##
  vm_size               = "Standard_D2s_v3" #keep##

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "jenkins-vm_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "jenkins-vm" #keep##
    admin_username = var.admin_username #you should keep it. but check variables.tf, you should find a variable called admin_username ##
  }
  os_profile_linux_config {
    disable_password_authentication = true #keep##
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub") ##you can keep it, if you have this file, id_rsa.pub in the folder ~/.ssh  ##
      path     = "/home/${var.admin_username}/.ssh/authorized_keys" ## ?? ## 
    }
  }



  #Create VM ##resource 7##
resource "aws_instance" "main" {
  ami           = "ami-02df9ea15c1778c9c"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main.id]
    tags = {
    Name = "jenkins-vm"
  }

  }


  #========================================
  ##??##
  provisioner "file" {
    source      = "~/.ssh/id_rsa.pub"
    destination = "public_key"

    connection {
      type        = "ssh"
      user        = var.admin_username
      host        = azurerm_public_ip.main.ip_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
}



##??##
  provisioner "file" {
    source      = "~/.ssh/id_rsa.pub"
    destination = "public_key"

    }
