resource "aws_subnet" "public_subnet" {
  vpc_id     =  "${var.vpc_id}"
  cidr_block = "10.0.0.0/24"


}
resource "aws_subnet" "private_subnet" {
  vpc_id     =  "${var.vpc_id}"
  cidr_block = "10.0.1.0/24"


}

resource "aws_eip" "main" {
   network_interface = aws_network_interface.main_vpc.id
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

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.internal.id
  route_table_id = aws_route_table.prod-route-table.id
}

