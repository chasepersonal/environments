variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "azs" {
  description = "AWS availability_zone"
  type        = "list"
  default     = ["us-east-2a", "us-east-2b"]
}

variable "vpc_name" {
  description = "Name of VPC"
  default     = "k3s-aws-vpc"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.128.0.0/16"
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

/* Fedora Core OS AMI for us-east-2 */
variable "amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-east-2 = "ami-087891c79012c7f54"
  }
}
