// Create S3 for Kops State
resource "aws_s3_bucket" "kops_state"{
  bucket = local.kops_state_bucket
  acl = "private"
  force_destroy = true
  tags = merge(local.tags)
}

// Create VPC

module "kops_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.kops_az
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.kops_cluster_name}"  = "shared"
    "terraform"                                         = "true"
  }

  // Tags required by k8s Ref https://github.com/terraform-aws-modules/terraform-aws-vpc
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = true
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = true
  }

}

// Create Security Group

resource "aws_security_group" "kops_sg_elb"{

  name = "sg-${local.kops_cluster_name}"
  vpc_id = module.kops_vpc.vpc_id
  tags = merge(local.tags)

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

}