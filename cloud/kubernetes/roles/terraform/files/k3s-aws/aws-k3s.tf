/* Setup our aws provider */
provider "aws" {
  version = "~> v2.33.0"

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

/* Set up key pair to use */
resource "aws_key_pair" "k3s" {
  key_name   = "k3s"
  public_key = file("~/.ssh/k3s_aws.pub")
}

/* Define our vpc */
resource "aws_vpc" "k3s" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "k3s-vpc"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "k3s" {
  vpc_id = aws_vpc.k3s.id
}

/* Public subnet */
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k3s.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.k3s]
  tags = {
    Name = "k3s-public-subnet"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k3s.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s.id
  }
  tags = {
    Name = "k3s-public-rt"
  }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

/* Default security group */
resource "aws_security_group" "public" {
  name        = "k3s-sg"
  description = "k3s security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = aws_vpc.k3s.id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

/* Worker servers */
resource "aws_instance" "k3s-worker" {
  count             = 3
  ami               = var.amis[var.region]
  instance_type     = "a1.large"
  subnet_id         = aws_subnet.public.id
  security_groups   = [aws_security_group.public.id]
  key_name          = aws_key_pair.k3s.key_name
  source_dest_check = true
  tags = {
    Name = "k3s-aws-w-${count.index}"
  }
}

/* Master server */
resource "aws_instance" "k3s-master" {
  count             = 1
  ami               = var.amis[var.region]
  instance_type     = "a1.large"
  subnet_id         = aws_subnet.public.id
  security_groups   = [aws_security_group.public.id]
  key_name          = aws_key_pair.k3s.key_name
  source_dest_check = true
  tags = {
    Name = "k3s-aws-m-${count.index}"
  }
}