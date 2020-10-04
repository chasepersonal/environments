/* Set up key pair to use */
resource "aws_key_pair" "openvpn_kp" {
  key_name   = "openvpn_kp"
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
    "terraform"                                  = "true"
  }
}

/* OpenVPN Security Group */
resource "aws_security_group" "openvpn_sg" {
  name        = "openvpn_sg"
  description = "security group for hanlding an OpenVPN server"
  vpc_id      = module.k3s_vpc.vpc_id

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

    from_port   = 8443
    protocol    = "tcp"
    to_port     = 8443
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 1194
    protocol    = "udp"
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openvpn-sg"
  }
}

/* Master server */
resource "aws_instance" "openvpn" {
  count             = 1
  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  subnet_id         = module.k3s_vpc.public_subnets[0]
  security_groups   = [aws_security_group.openvpn_sg.id]
  key_name          = aws_key_pair.openvpn_kp.key_name
  source_dest_check = true
  tags = {
    Name = "openvpn-server"
  }
}

/* Output the master node ip addresses */

output "master_ip_addr" {
  value       = aws_instance.openvpn.public_ip
  description = "Show the openvpn public ip"
}