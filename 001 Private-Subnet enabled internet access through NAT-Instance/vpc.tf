#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# VPC
variable "CIDR_VPC" {
  type = string
  default = "10.0.0.0/16"
}


# PublicSubnet 1 - AZ 2
variable "CIDR_PublicSubnet1_AZ1" {
  type = string
  default = "10.0.1.0/24"
}

# PublicSubnet 1 - AZ2
variable "CIDR_PublicSubnet1_AZ2" {
  type = string
  default = "10.0.2.0/24"
}

# PrivatecSubnet 1 - AZ1 (NAT)
variable "CIDR_PrivateSubnet1_AZ1" {
  type = string
  default = "10.0.3.0/24"
}

# PrivateSubnet 1 - AZ2 (NAT)
variable "CIDR_PrivateSubnet1_AZ2" {
  type = string
  default = "10.0.4.0/24"
}


#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# VPC general
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Create a VPC
resource "aws_vpc" "VPC" {
  cidr_block = var.CIDR_VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.ProjectName}VPC"
  }
}

# create internet gateway
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${var.ProjectName}InternetGateway"
  }
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Subnets
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# public Subnet 1 - AZ1
resource "aws_subnet" "PublicSubnet1AZ1" {
  vpc_id = aws_vpc.VPC.id
  map_public_ip_on_launch = true
  availability_zone = "${var.Region}${var.AZ1}"  
  cidr_block = var.CIDR_PublicSubnet1_AZ1
  tags = {
    Name = "${var.ProjectName}VPC-public1-${var.AZ1}"
  }
}

# public Subnet 1 - AZ2
resource "aws_subnet" "PublicSubnet1AZ2" {
  vpc_id = aws_vpc.VPC.id
  map_public_ip_on_launch = true
  availability_zone = "${var.Region}${var.AZ2}"  
  cidr_block = var.CIDR_PublicSubnet1_AZ2
  tags = {
    Name = "${var.ProjectName}VPC-public1-${var.AZ2}"
  }
}

# private Subnet 1 - AZ1 (NAT-enabled)
resource "aws_subnet" "PrivateSubnet1AZ1" {
  vpc_id = aws_vpc.VPC.id
  map_public_ip_on_launch = false
  availability_zone = "${var.Region}${var.AZ1}"  
  cidr_block = var.CIDR_PrivateSubnet1_AZ1
  tags = {
    Name = "${var.ProjectName}VPC-private1-${var.AZ1}"
  }
}

# private Subnet 1 - AZ2 (NAT-enabled)
resource "aws_subnet" "PrivateSubnet1AZ2" {
  vpc_id = aws_vpc.VPC.id
  map_public_ip_on_launch = false
  availability_zone = "${var.Region}${var.AZ2}"  
  cidr_block = var.CIDR_PrivateSubnet1_AZ2
  tags = {
    Name = "${var.ProjectName}VPC-private1-${var.AZ2}"
  }
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Elatic puclib IP which is necessary for the NAT-Instance.
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat-instance-az1" {
  vpc = true
  network_interface = aws_network_interface.nat-instance-az1-primary.id
  tags = {
    Name = "nat-instance-az1"
  }
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Routing table for the public network
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# routing table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name        = "${var.ProjectName}-routing-table-public"
  }
}

# main route table
resource "aws_main_route_table_association" "MainRouteTable" {
  vpc_id         = aws_vpc.VPC.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

# public route
resource "aws_route" "PublicRoute" {
  route_table_id         = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.InternetGateway.id
}

# route association for PublicSubnet1-AZ1 zuordnen
resource "aws_route_table_association" "PublicSubnet1AZ1_Route" {
  subnet_id      = aws_subnet.PublicSubnet1AZ1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

# route association for PublicSubnet1-AZ2 zuordnen
resource "aws_route_table_association" "PublicSubnet1AZ2_Route" {
  subnet_id      = aws_subnet.PublicSubnet1AZ2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Routing table for the NAT-Enabled private network
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# routing table
resource "aws_route_table" "PrivateRouteTableNat" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name        = "${var.ProjectName}-routing-table-private-nat"
  }
}

# private route to the NAT-Instance.
# This is important. All internal traffic from the private-subnet will be routed to the NAT-Instance.
resource "aws_route" "PrivateRouteNat" {
  route_table_id         = aws_route_table.PrivateRouteTableNat.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_network_interface.nat-instance-az1-primary.id
}

# route association for PrivateSubnet1-AZ1 (NAT)
resource "aws_route_table_association" "PrivateSubnet1AZ1_RouteNat" {
  subnet_id      = aws_subnet.PrivateSubnet1AZ1.id
  route_table_id = aws_route_table.PrivateRouteTableNat.id
}

# route association for PrivateSubnet1-AZ2 (NAT)
resource "aws_route_table_association" "PrivateSubnet1AZ2_RouteNat" {
  subnet_id      = aws_subnet.PrivateSubnet1AZ2.id
  route_table_id = aws_route_table.PrivateRouteTableNat.id
}

