resource "aws_security_group" "apache" {
  name        = "apache-sg"
  description = "Allow enduser "
#  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description     = "connecting to enduser"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]

  }

  ingress {
    description     = "connecting from admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]


  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "apache-sg"
  }
}


resource "aws_instance" "apache" {
  ami           = "ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  #  vpc_id = "aws_vpc.dev-vpc.id"
  subnet_id              = aws_subnet.dev-private[0].id
  vpc_security_group_ids = [aws_security_group.apache.id]
#  key_name        = "${aws_key_pair.singapore-pem.id}"


  tags = {
    Name = "dev-apache"
  }
}








#resource "aws_key_pair" "singapore" {
#  key_name   = "singapore-pem"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFmmvR9ycaZyq2sIWlnp5qpeBXL5ZNZ23EXfqz8Y/W5naDQfHFI2BREcPj5ug+Bz/fBDdzbmt29r8dHNXsujjIMtYnW4sGOVFXrndNOptWSb9Or6tfQ26fAmxUmEkU1GVaL3rcCS6OhOjzodVH6L3hfGMUFf6z0PaSpcZH9013dqInEQvJozFodkYsqlkhqvE33fZ0j4/pKlay7Pm81eW4gdeMXRXyXF9hzRd9hNygc8SE42uH//cxfJUwXbGnCWI8r2PYoo5FDHvIJoNnJ89ayZDVwPaTRweBR4Fjff6+awGYiddNztK/GNHjDM1hFaD21bIm6bJeZu+jAw1rn/jnE+7rIcVKkY2tussPN1JZrXdzWVV/B8F1/Oqw+TnP6oi9NmDtDf1HzP/Jpm4yiSl66rVeULSavCXDBO64itT4moI28VkFWv9xPCDTng1y5vP7O4g2a5o3QSEdWqx1VFpFF7gF+1eUa2CyU+u9aOAT4hcMmLes9xf+4lExdCszxs= DEEPALI REDDY@DESKTOP-5FCHM4B"

#}