### List of things  to deploy
# 1. Create a VPC
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a subnet
# 5. Associate subnet with Route Table
# 6. Create Security Group to allo port 22, 80, 443
# 7. Create a network interface with an IP in the subnet that was created in step 4
# 8. Assign an elastic IP to the network interface created in step 7 
# 9. Create Ubuntu Server and insta;;/enable apache2

# Provider
provider "aws" {
  region  = "us-east-1"
  access_key: xxxxxxxxxxxxx
  secrete_key: yyyyyyyyyyyyy
}
## Resources
#resource "<provider>_<resource_type>" "name" {   
#}


terraform {
  required_version = ">= 0.12.0"
}

# 1. Create a VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "production"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  }
}
# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    name = "Prod"
  }
  
# 4. Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22, 80, 443
module "dev_ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2_sg"
  description = "Security group for ec2_sg"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress_cidr_blocks = ["205.175.212.203/32"]
  ingress_rules       = ["ssh-tcp"]
}

module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2_sg"
  description = "Security group for ec2_sg"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

# 7. Create a network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 8. Assign an elastic IP to the network interface created in step 7 
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

# 9. Create an Elastic Container Registry Repository.
resource "aws_ecr_repository" "Container_Registry" {
  name                 = "Container_Registry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
} 

# 10. Create Ubuntu Server and EC2 instance And install docker & terraform
resource "aws_instance" "web-server-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  availability_zone = "us-east-1"
  Key_name = "main-key"
  
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
	
	# Install unzip
    sudo apt-get install unzip
    # Confirm the latest version number on the terraform website:
    https://www.terraform.io/downloads.html
    # Download latest version of the terraform (substituting newer version number if needed)
    sudo wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip
    sudo unzip terraform_1.0.7_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
	sudo install /usr/local/bin/terraform
  EOF
}

# 11. Create Role for the EC2
resource "aws_iam_role" "web-server-instance" {
  name = "web-server-instance"

  assume_role_policy = <<EOF
{
  "Version": "2023-01-30",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

# 12. Create Profile for the EC2
resource "aws_iam_instance_profile" "ec2_profile_web-server-instance" {
  name = "ec2_profile_web-server-instance"
  role = aws_iam_role.web-server-instance.name
}

# 12. Create EC2 Policy
resource "aws_iam_role_policy" "ec2_policy_web-server-instance" {
  name = "ec2_policy_web-server-instance"
  role = aws_iam_role.web-server-instance.id

  policy = <<EOF
 {
  "Version": "2023-01-30",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Effect": "Allow",
      "Resource": "Container_Registry"
    }
  ]
 }
EOF
}
