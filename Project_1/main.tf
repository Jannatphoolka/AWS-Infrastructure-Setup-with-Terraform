provider "aws" {
    # version = "~> 2.0"
    region = "us-east-2"
    access_key = ""
    secret_key = ""
}

# provider "azure" {
  
# }

# resource "aws_instance" "my-first-server" {
#   ami           = "ami-036841078a4b68e14"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
# }

# # How to create resources
# # resource "<provider>_<resource_type>" "name" {
# #     config options...
# #     key = "value"
# #     key2 = "value2" 
# # }

# # aws vpc
# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"
# }

# # aws sub-net
# resource "aws_vpc" "second-vpc" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "subnet" {
#   vpc_id     = aws_vpc.second-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "vpc-2-subnet"
#   }
# }

# 1. Terraform vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}
# 2. Terraform aws Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

}
# 3. Create custom route table
resource "aws_route_table" "route-tb" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # send all traffic to int. gw
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# 4. Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-tb.id
}

# create security group to allow ports 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  tags = {
    Name = "allow_web"
  }


  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "HTTP"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. terraform aws network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. assign an elastic ip to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                    = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  # References in depends_on must be to a whole object (resource, etc), not to an attribute of an object.
  depends_on = [aws_internet_gateway.gw] # pass in a list to specify multiple things to weigh upon 
}

# 9. Create ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami = "ami-036841078a4b68e14"
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  key_name = "mykey"

  network_interface {
    device_index = 0 # first network interface
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server! > /var/www/html/index.html'
EOF
  tags = {
    Name = "web-server"
  }

}