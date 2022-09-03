#provider "aws" {
# region = "ap-southeast-1"
#}

#create the vpc
resource "aws_vpc" "dev-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "dev-vpc"
  }
}


#crate igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }

  depends_on = [
    aws_vpc.dev-vpc
  ]
}


#Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#creae pub-sunet
resource "aws_subnet" "dev-pub" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = element(var.pub_cidr, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "dev-pub-${count.index + 1}-subnet"
  }
}

resource "aws_subnet" "dev-private" {
  count      = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = element(var.private_cidr, count.index)
  #  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "dev-private-${count.index + 1}-subnet"
  }
}



resource "aws_subnet" "dev-data" {
  count      = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = element(var.data_cidr, count.index)
  #  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "dev-data-${count.index + 1}-subnet"
  }
}


#create eip

resource "aws_eip" "dev-eip" {
  vpc = true
}

#create nat_gateway in pub sub

resource "aws_nat_gateway" "dev-ngw" {
  allocation_id = aws_eip.dev-eip.id
  subnet_id     = aws_subnet.dev-pub[1].id

  tags = {
    Name = " dev-Ngw"
  }
}

#create rout table and rout

resource "aws_route_table" "dev-rout-pub" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "dev-pub-route"
  }
}


resource "aws_route_table" "dev-rout-private" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev-ngw.id
  }
  tags = {
    Name = "dev-private-route"
  }
}



resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.dev-pub[*].id)
  subnet_id      = element(aws_subnet.dev-pub[*].id, count.index)
  route_table_id = aws_route_table.dev-rout-pub.id
}


resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.dev-private[*].id)
  subnet_id      = element(aws_subnet.dev-private[*].id, count.index)
  route_table_id = aws_route_table.dev-rout-private.id
}


resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.dev-data[*].id)
  subnet_id      = element(aws_subnet.dev-data[*].id, count.index)
  route_table_id = aws_route_table.dev-rout-private.id
}





 