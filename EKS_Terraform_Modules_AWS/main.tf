provider "aws" {
  region = var.location
}

resource "aws_instance" "demo-server" {
  ami                    = var.os_name
  instance_type          = var.instance-type
  key_name               = aws_key_pair.T_ssh_key.key_name
  subnet_id              = aws_subnet.demo_subnet_01.id
  vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]

  tags = {
    Name = "${var.instance_name}01"
  }
}

// Create VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}VPC01"
  }
}

// Create a key pair for ssh
resource "aws_key_pair" "T_ssh_key" {
  key_name   = "${var.env_prefix}serverkey"
  public_key = file(var.key)
}

// Create Subnet
resource "aws_subnet" "demo_subnet_01" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.subnet_cidr_01
  availability_zone       = var.subent_az_01
  map_public_ip_on_launch = "true"

  tags = {
    Name = "demo_subnet_01"
  }
}

// Create Subnet
resource "aws_subnet" "demo_subnet_02" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.subnet_cidr_02
  availability_zone       = var.subent_az_02
  map_public_ip_on_launch = "true"

  tags = {
    Name = "demo_subnet_02"
  }
}

// Create Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
    Name = "demo-rt"
  }
}

// associate subnet with route table 
resource "aws_route_table_association" "demo-rt_association_01" {
  subnet_id      = aws_subnet.demo_subnet_01.id
  route_table_id = aws_route_table.demo-rt.id
}

// associate subnet with route table 
resource "aws_route_table_association" "demo-rt_association_02" {
  subnet_id      = aws_subnet.demo_subnet_02.id
  route_table_id = aws_route_table.demo-rt.id
}

// create a security group
resource "aws_security_group" "demo-vpc-sg" {
  name   = "demo-vpc-sg"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#################################################################################################################

module "sgs" {
  source = "./Sg_EKS"
  vpc_id = aws_vpc.demo-vpc.id
}

module "eks" {
  source     = "./EKS"
  sg_ids     = module.sgs.security_group_public
  vpc_id     = aws_vpc.demo-vpc.id
  subnet_ids = [aws_subnet.demo_subnet_01.id, aws_subnet.demo_subnet_02.id]
}
