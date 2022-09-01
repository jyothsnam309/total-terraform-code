data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Allow admin to ssh"
#  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description = "connecting to admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-bastion-sg"
  }
}




resource "aws_instance" "bastion" {
  ami           = "ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  #  vpc_id = "aws_vpc.stage-vpc.id"
  subnet_id              = aws_subnet.stage-pub[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags = {
    Name = "stage-bastion"
  }
}




