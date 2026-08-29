
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}


##########################################################################
#-----------------------------MAIN SERVER--------------------------------#
##########################################################################



data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}
data "aws_caller_identity" "current" {}


locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

resource "aws_instance" "devops_server" {
  #checkov:skip=CKV_AWS_135: np EBS so far
  #checkov:skip=CKV_AWS_126: no monitoring so far
  #checkov:skip=CKV2_AWS_41:no need in role profile in this project
  ami                    = "ami-080254318c2d8932f"
  instance_type          = "t3.small"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops1_sg.id]
  subnet_id = aws_subnet.devops1_public_subnet.id
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    #metadata for a sserver now exists; session token is required
  }
  tags = {
    Name = "devops-project-server"
  }
}

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


##########################################################################
#-----------------------------DB SERVER----------------------------------#
##########################################################################


resource "aws_instance" "server_for_db" {
  #checkov:skip=CKV_AWS_135: np EBS so far
  #checkov:skip=CKV_AWS_126: no monitoring so far
  ami                    = "ami-080254318c2d8932f"
  instance_type          = "t3.micro"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops1_db_sg.id]
  subnet_id = aws_subnet.devops1_private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.DB_instance_profile.name
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  tags = {
    Name = "devops-db-server"
  }
}