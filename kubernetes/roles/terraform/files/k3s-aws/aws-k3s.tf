/* Setup our aws provider */
provider "aws" {
  version = "~> v2.53.0"

  region                  = var.region
  shared_credentials_file = "$HOME/.aws/credentials"

}

/* Set up key pair to use */
resource "aws_key_pair" "k3s_cluster_kp" {
  key_name   = "k3s_cluster"
  public_key = file("~/.ssh/k3s_aws.pub")
}

/* Set up VPC with internet gateway */

module "k3s_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs

  tags = {
    "kubernetes.io/cluster/k3s-aws-cpw-cluster"  = "shared"
    "terraform"                                  = "true"
  }

  // Tags required by k8s Ref https://github.com/terraform-aws-modules/terraform-aws-vpc

  public_subnet_tags = {
    "kubernetes.io/role/elb" = true
  }

}

/* Cluster security group */
resource "aws_security_group" "k3s_worker_sg" {
  name        = "k3s_worker_sg"
  description = "k3s security group tailored to all nodes in the cluster"
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
    cidr_blocks = var.public_subnet_cidrs
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = var.public_subnet_cidrs
  }

  ingress {

    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = var.public_subnet_cidrs

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-worker-sg"
  }
}

/* Cluster security group */
resource "aws_security_group" "k3s_master_sg" {
  name        = "k3s_mater_sg"
  description = "k3s security group tailored to all nodes in the cluster"
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 6443
    protocol    = "tcp"
    to_port     = 6443
    cidr_blocks = var.public_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-master-sg"
  }
}

/* Master server */
resource "aws_instance" "k3s_master" {
  count             = 1
  ami               = var.amis[var.region]
  instance_type     = "t2.large"
  subnet_id         = module.k3s_vpc.public_subnets[0]
  security_groups   = [aws_security_group.k3s_master_sg.id]
  key_name          = aws_key_pair.k3s_cluster_kp.key_name
  source_dest_check = true
  tags = {
    Name = "k3s-aws-m-${count.index}"
  }
}

/* Output the master node ip addresses */

output "master_ip_addr" {
  value       = aws_instance.k3s_master[0].public_ip
  description = "Show all of the master node ip addresses"
}

/* Worker servers */
resource "aws_instance" "k3s_worker" {
  count             = 3
  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  subnet_id         = module.k3s_vpc.public_subnets[0]
  security_groups   = [aws_security_group.k3s_worker_sg.id]
  key_name          = aws_key_pair.k3s_cluster_kp.key_name
  source_dest_check = true
  tags = {
    Name = "k3s-aws-w-${count.index}"
  }
}

/* Output the worker ip addresses */

output "worker_ip_addr" {
  value       = aws_instance.k3s_worker[*].public_ip
  description = "Show all of the worker node ip addresses"
}
