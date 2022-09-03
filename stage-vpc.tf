provider "aws" {
 region = "ap-south-1"
}

#create the vpc
resource "aws_vpc" "stage-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "stage-vpc"
  }
}


#crate igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.stage-vpc.id

  tags = {
    Name = "stage-igw"
  }

  depends_on = [
    aws_vpc.stage-vpc
  ]
}


#Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#creae pub-sunet
resource "aws_subnet" "stage-pub" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.stage-vpc.id
  cidr_block              = element(var.pub_cidr, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-pub-${count.index + 1}-subnet"
  }
}

resource "aws_subnet" "stage-private" {
  count      = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.stage-vpc.id
  cidr_block = element(var.private_cidr, count.index)
  #  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "stage-private-${count.index + 1}-subnet"
  }
}



resource "aws_subnet" "stage-data" {
  count      = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.stage-vpc.id
  cidr_block = element(var.data_cidr, count.index)
  #  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "stage-data-${count.index + 1}-subnet"
  }
}


#create eip

resource "aws_eip" "stage-eip" {
  vpc = true
}

#create nat_gateway in pub sub

resource "aws_nat_gateway" "stage-ngw" {
  allocation_id = aws_eip.stage-eip.id
  subnet_id     = aws_subnet.stage-pub[1].id

  tags = {
    Name = " stage-Ngw"
  }
}

#create rout table and rout

resource "aws_route_table" "stage-rout-pub" {
  vpc_id = aws_vpc.stage-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "stage-pub-route"
  }
}


resource "aws_route_table" "stage-rout-private" {
  vpc_id = aws_vpc.stage-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.stage-ngw.id
  }
  tags = {
    Name = "stage-private-route"
  }
}



resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.stage-pub[*].id)
  subnet_id      = element(aws_subnet.stage-pub[*].id, count.index)
  route_table_id = aws_route_table.stage-rout-pub.id
}


resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.stage-private[*].id)
  subnet_id      = element(aws_subnet.stage-private[*].id, count.index)
  route_table_id = aws_route_table.stage-rout-private.id
}


resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.stage-data[*].id)
  subnet_id      = element(aws_subnet.stage-data[*].id, count.index)
  route_table_id = aws_route_table.stage-rout-private.id
}





 