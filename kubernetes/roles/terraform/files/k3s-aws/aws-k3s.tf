/* Setup our aws provider */
provider "aws" {
  version = "~> v2.53.0"

  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

/* Set up key pair to use */
resource "aws_key_pair" "k3s" {
  key_name   = "k3s"
  public_key = file("~/.ssh/k3s_aws.pub")
}

/* Set up VPC with internet gateway */

module "k3s_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/k3s-aws-cpw-cluster"  = "shared"
    "terraform"                                  = "true"
  }

  // Tags required by k8s Ref https://github.com/terraform-aws-modules/terraform-aws-vpc
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = true
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = true
  }

}

/* Default security group */
resource "aws_security_group" "k3s_public_sg" {
  name        = "k3s-sg"
  description = "k3s security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = module.k3s_vpc.vpc_id

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
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = var.ingress_cidrs
  }

  ingress {

    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = var.ingress_cidrs

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-public-sg"
  }
}

/* Worker servers */
resource "aws_instance" "k3s-worker" {
  count             = 3
  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
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
