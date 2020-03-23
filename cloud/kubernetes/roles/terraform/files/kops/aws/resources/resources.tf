// Create S3 for Kops State
resource "aws_s3_bucket" "kops-state"{
  bucket = "${local.kops_state_bucket}"
  acl = "private"
  force_destroy = true
  tags = "${merge(local.tags)}"
}

// Create Security Group

resource "aws_security_group" "kops-sg"{

  name = "sg-${local.kops_cluster_name}"
  vpc_id = "${module.blog_vpc.vpc_id}"
  tags = "${merge(local.tags)}"

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