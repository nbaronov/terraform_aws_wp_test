resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress_sg"
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id      = aws_vpc.infrastructure_vpc.id

  dynamic "ingress" {
    for_each = var.inbound_ports_production
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow traffic on port 3306 from wordpress security group"
  vpc_id      = aws_vpc.infrastructure_vpc.id

  ingress {
    description     = "Allow MySQL traffic from wordpress security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Allow EFS traffic"
  vpc_id      = aws_vpc.infrastructure_vpc.id
  ingress {
    description     = "EFS mount target"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
