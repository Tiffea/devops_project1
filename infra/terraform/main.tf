
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

locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}


resource "aws_instance" "devops_server" {
  ami                    = "ami-080254318c2d8932f"
  instance_type          = "t3.small"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.devops1_sg.id]
  subnet_id = aws_subnet.devops1_public_subnet.id
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = {
    Name = "devops-project-server"
  }
}

resource "aws_eip" "devops_eip" {
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
  tags = {
    Name = "devops-db-server"
  }
}