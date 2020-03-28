variable "region" {
  description = "AWS region for build"
  default = "us-east-2"
}

variable "vpc_name" {
  description = "Name for VPC"
  default = "kops-aws-vpc"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "10.0.0.0/16"
}

variable "kops_az" {
  description = "AWS availability zone for kops build"
  type = "list"
  default = ["us-east-1a", "us-east-2b", "us-east-2c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR for private subnets"
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR for public subnets"
  type = "list"
  default = ["10.0.101.0/24"]
}

variable "ingress_cidrs" {
  description = "CIDRS for AWS ingress points"
  type = "list"
  default = ["10.0.0.80/32" , "10.0.0.81/32"]
}

