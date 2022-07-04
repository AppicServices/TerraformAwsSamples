

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SecurityGroup for NAT-Instance
# This one is for AZ1. It is recommended to put a Nat-Instance in every AZ you are using in order to reduce traffic between AZ. 
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "nat-instance-az1" {
  name = "nat-instance-az1"
  vpc_id = aws_vpc.VPC.id

  # only inbound traffic from the private network is allowed
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["${var.CIDR_PrivateSubnet1_AZ1}","${var.CIDR_PrivateSubnet1_AZ2}"]  # normally you make the SG for each AZ. But for this example we only maintain one NAT-Instance.
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "nat-instance-az1"
  }

}

# explicit network interface for the NAT-Instance. We need it to address it in the routing-table.
resource "aws_network_interface" "nat-instance-az1-primary" {
  subnet_id   = aws_subnet.PublicSubnet1AZ1.id
  security_groups = [aws_security_group.nat-instance-az1.id] 
  source_dest_check = false

  tags = {
    Name = "nat-instance-az1-primary"
  }
}

# NAT-Instance. We use default Amazon Linux 2 and modify it to a NAt-Instance. 
resource "aws_instance" "nat-instance-az1" {
  ami                    = "ami-0a1ee2fb28fe05df3"   
  instance_type          = "t3.nano" # very cheap instance and also have 5GBit bandwith.
  ebs_optimized          = false
  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sysctl -w net.ipv4.ip_forward=1
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF

  # add the network-interface
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.nat-instance-az1-primary.id
  }
  
  tags = {
    Name                   = "nat-instance-az1"
  }
}


