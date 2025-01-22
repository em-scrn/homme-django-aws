###############################
# AWS infra to host django app
###############################

# Create a Virtual Private Cloud to isolate the infrastructure
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Internet Gateway to allow internet access to the VPC
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.app_name}-ec2-igw"
  }
}

# Route table for controlling traffic leaving the VPC
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.app_name}-ec2-rt"
  }
}

# Subnet within VPC for resource allocation, in availability zone ap-southeast-2a
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-southeast-2a"
  tags = {
    Name = "${var.app_name}-ec2-subnet1"
  }
}

# Another subnet for redundancy, in availability zone ap-southeast-2b
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-southeast-2b"
  tags = {
    Name = "${var.app_name}-ec2-subnet2"
  }
}

# Associate subnets with route table for internet access
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.default.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.default.id
}



# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg"
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.app_name}-ec2-sg"
  }
}

# Split the ingress and egress rules from SG as per best practice from TF
resource "aws_vpc_security_group_ingress_rule" "ec2_sg_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  # from_port = 0
  # to_port = 0
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# EC2 instance for the local web app
resource "aws_instance" "web" {
  ami                    = "ami-0d6560f3176dc9ec0" # Amazon Linux
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet1.id # Place this instance in one of the private subnets
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  associate_public_ip_address = true # Assigns a public IP address to your instance
  user_data_replace_on_change = true # Replace the user data when it changes

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    yum update -y
    yum install -y yum-utils

    # Install Docker
    yum install -y docker
    service docker start

    # Install AWS CLI
    yum install -y aws-cli

    # Authenticate to ECR
    docker login -u AWS -p $(aws ecr get-login-password --region ap-southeast-2) ${aws_ecr_repository.django_aws_repo.repository_url}:latest

    # Pull the Docker image from ECR
    docker pull --platform linux/amd64 ${aws_ecr_repository.django_aws_repo.repository_url}:latest

    # Run the Docker image
    docker run --platform linux/amd64 -d -p 80:8080 \
        --env SECRET_KEY="${var.secret_key}" \
        --env DB_NAME=${aws_db_instance.default.db_name} \
        --env DB_USER_NM=${aws_db_instance.default.username} \
        --env DB_USER_PW=${aws_db_instance.default.password} \
        --env DB_IP=${aws_db_instance.default.address} \
        --env DB_PORT=5432 \
        ${aws_ecr_repository.django_aws_repo.repository_url}:latest
    EOF
    

  tags = {
    Name = "homme-django-server"
  }
}

# IAM role for EC2 instance to access ECR
resource "aws_iam_role" "ec2_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com",
      },
      Effect = "Allow",
    }],
  })
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the role
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_name}-profile"
  role = aws_iam_role.ec2_role.name
}

###############################
# s3 and related resources for django static hosting 
###############################
resource "aws_s3_bucket" "django_s3" {
  bucket = "${var.app_name}-static-media"

  tags = { 
    Name = "${var.app_name}-s3-bucket" 
  }
}

resource "aws_s3_bucket_ownership_controls" "django_s3_bucket_ownership" {
  bucket = aws_s3_bucket.django_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "django_s3_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.django_s3_bucket_ownership]

  bucket = aws_s3_bucket.django_s3.id
  acl    = "private"
}

# iam 
resource "aws_s3_bucket_policy" "allow_access_to_s3_policy" {
  bucket = aws_s3_bucket.django_s3.id
  policy = data.aws_iam_policy_document.allow_access_to_s3.json
}

data "aws_iam_policy_document" "allow_access_to_s3" {
  statement { 
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.django_s3.arn}/*",
    ]
  }
}

resource "aws_iam_user" "s3_access_iam_user" {
  name = "${var.app_name}-s3-user"
  permissions_boundary = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#ecr
resource "aws_ecr_repository" "django_aws_repo" {
  name                 = "${var.ecr_app_name}"
  image_tag_mutability = "MUTABLE" 
  tags = {
    Name = "${var.ecr_app_name}-ecr"
  }
}

resource "aws_ecr_repository_policy" "django_aws_policy" {
  repository = aws_ecr_repository.django_aws_repo.name

  policy = data.aws_iam_policy_document.ecr_policy.json
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "PublicRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

