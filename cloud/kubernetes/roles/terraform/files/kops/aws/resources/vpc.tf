module "kops_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.kops_az
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.kops_cluster_name}"    = "shared"
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