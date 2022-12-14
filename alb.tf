resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow to enduser"
  vpc_id      = aws_vpc.stage-vpc.id

  ingress {
    description = "connecting to end user"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


