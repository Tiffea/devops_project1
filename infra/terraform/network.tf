# create a new separate vpc
resource "aws_vpc" "devops1_vpc" {
    cidr_block = "10.0.0.0/16" 
    
    tags = {Name = "devops1_vpc"}
}

#get a slice of addresess for subnets
resource "aws_subnet" "devops1_subnet" {
    vpc_id = aws_vpc.devops1_vpc.id
    cidr_block = "10.0.1.0/24"
}

#create a door for an internet
resource "aws_internet_gateway" "devops1_gateway" {
    vpc_id = aws_vpc.devops1_vpc.id
}

#routing - open door in web
resource "aws_route_table" "devops1_route_table" {
	vpc_id = aws_vpc.devops1_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops1_gateway.id
    }
}

# linking subnet and route table to the new VPC
resource "aws_route_table_association" "devops1_table_association" {

    subnet_id = aws_subnet.devops1_subnet.id
    route_table_id = aws_route_table.devops1_route_table.id
}