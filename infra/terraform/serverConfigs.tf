#SECTION - pre-settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  backend "s3" {
    bucket         = "tf-bucket-p4523432"
    key            = "devops-project1/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "DynamoDB-for-tfstate"
    encrypt        = true
  }
}

# choose a region
provider "aws" {
  region = "eu-north-1"
}

# returns your AWS account id
data "aws_caller_identity" "current" {}

# return your ip
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

# return your current ip for TERRAFORM NEEDS (locally)
locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

#!SECTION
#SECTION - MAIN server configuration



resource "aws_instance" "devops_server" {
  #checkov:skip=CKV_AWS_135: np EBS so far
  #checkov:skip=CKV_AWS_126: no monitoring so far
  #checkov:skip=CKV2_AWS_41:no need in role profile in this project
  ami                    = "ami-080254318c2d8932f"
  instance_type          = "t3.small"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops1_sg.id]
  subnet_id              = aws_subnet.devops1_public_subnet.id
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
    # metadata for a sserver now exists; session token is required
  }
  tags = {
    Name = "devops-project-server"
  }
}

#SECTION - public EIP for the server

resource "aws_eip" "devops_eip" {
  #checkov:skip=CKV2_AWS_19: false positive > eip is attached
  instance = aws_instance.devops_server.id

  tags = {
    Name = "devops-project-eip"
  }
}

output "new_server_ip" {
  value = aws_eip.devops_eip.public_ip
}
#!SECTION -end of eip section
#!SECTION


#SECTION - DB server confugitation
resource "aws_instance" "server_for_db" {
  #checkov:skip=CKV_AWS_135: np EBS so far
  #checkov:skip=CKV_AWS_126: no monitoring so far
  ami                    = "ami-080254318c2d8932f"
  instance_type          = "t3.micro"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops1_db_sg.id]
  subnet_id              = aws_subnet.devops1_private_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.DB_instance_profile.name
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  tags = {
    Name = "devops-db-server"
  }
}
#!SECTION

#SECTION - NAT as a server
#NOTE - AWS limits outgoing internet bandwidth on EC2 instances to 5Gbps.
#This means that the highest bandwidth that fck-nat can support (while remaining cost-effective) is 5Gbps.

module "fck-nat" {
  source = "git::https://github.com/RaJiska/terraform-aws-fck-nat.git?ref=d5ef759"
  name                 = "devops1-fck-nat"
  vpc_id               = aws_vpc.devops1_vpc.id
  subnet_id            = aws_subnet.devops1_public_subnet.id  
  update_route_tables = true
  instance_type = "t4g.nano"
  #eip_allocation_ids = [aws_eip.nat_eip.id]

  #it generates a route for me
  route_tables_ids = {
    private = aws_route_table.devops1_private_route_table.id
  }
  #it routes the traffic to the private table
}

#no need but drags additional cost if set
# resource "aws_eip" "nat_eip" {
#     tags = {Name = "devops1-fck-nat-eip"}
# }
#!SECTION