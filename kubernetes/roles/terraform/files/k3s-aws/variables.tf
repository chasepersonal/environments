variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret access key"
}

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

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.128.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.128.1.0/24"
}

/* Fedora Core OS AMI for us-east-2 */
variable "amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-east-2 = "ami-087891c79012c7f54"
  }
}
