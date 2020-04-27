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
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR for public subnets"
  type = "list"
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

/* Ubuntu 20.04 AMI for us-east-2 */
variable "amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-east-2 = "ami-0e84e211558a022c0"
  }
}
