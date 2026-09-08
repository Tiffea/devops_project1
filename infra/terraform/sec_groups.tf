#SECTION - MAIN sequrity group rules
resource "aws_security_group" "devops1_sg" {
  name        = "devops-project-sg"
  description = "Security group for Devops project"
  vpc_id      = aws_vpc.devops1_vpc.id


  ingress {
    description = "SSH from operator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }
  #checkov:skip=CKV_AWS_260:http must be public
  ingress {
    description = "http connection to the net"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https connection to the net"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana port for monitoring (operator IP)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    description = "Prometheus (operator IP)"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }
  #checkov:skip=CKV_AWS_382:can be open for a public server
  egress {
    description = "all the outbound trafic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#!SECTION

#SECTION - DB security group rules
resource "aws_security_group" "devops1_db_sg" {
  name        = "devops-db-sg"
  description = "SG for postgres for secure placement"
  vpc_id      = aws_vpc.devops1_vpc.id

  ingress {
    description     = "Postgres from app SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.devops1_sg.id]
  }
  # rules for outboud DB traffic
  egress {
    description = "HTTPS (docker hub, apt, SSM)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "HTTP out (apt mirrors)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#!SECTION