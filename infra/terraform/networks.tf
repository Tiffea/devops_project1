##########################################################################
#-----------------------------PUBLIC SUBNET------------------------------#
#------------------------------------------------------------------------#

resource "aws_vpc" "devops1_vpc" {
  #checkov:skip=CKV2_AWS_11: no need in flow loging for a study project so far
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "devops1_vpc" }
}

resource "aws_subnet" "devops1_public_subnet" {
  vpc_id     = aws_vpc.devops1_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "devops1_gateway" {
  vpc_id = aws_vpc.devops1_vpc.id
}

resource "aws_route_table" "devops1_route_table" {
  vpc_id = aws_vpc.devops1_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops1_gateway.id
  }
}

# linking subnet and route table to the new VPC
resource "aws_route_table_association" "devops1_table_association" {

  subnet_id      = aws_subnet.devops1_public_subnet.id
  route_table_id = aws_route_table.devops1_route_table.id
}


resource "aws_default_security_group" "devops1_default_sg" {
  vpc_id = aws_vpc.devops1_vpc.id
  # devops1_sg is now a default security group by default
}

##########################################################################
#-----------------------------PRIVATE SUBNET-----------------------------#
#------------------------------------------------------------------------#



resource "aws_subnet" "devops1_private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.devops1_vpc.id
}

resource "aws_eip" "devops1_nat_eip" {
  #checkov:skip=CKV2_AWS_19: nat eip is never attached to an instance directly
  tags = { Name = "devops1_nat_eip" }
}

resource "aws_nat_gateway" "devops1_nat_gateway" {
  allocation_id = aws_eip.devops1_nat_eip.id
  subnet_id     = aws_subnet.devops1_public_subnet.id
}

resource "aws_route_table" "devops1_private_route_table" {
  vpc_id = aws_vpc.devops1_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops1_nat_gateway.id
  }
}

resource "aws_route_table_association" "devops1_route_table_association" {
  subnet_id      = aws_subnet.devops1_private_subnet.id
  route_table_id = aws_route_table.devops1_private_route_table.id
}
