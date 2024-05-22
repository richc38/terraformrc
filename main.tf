// vpc 
resource "aws_vpc" "vpc1" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc1"
  }
}

// 2 public subnets
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

// internet gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw1"
  }
}

// route table
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
  tags = {
    Name = "rt1"
  }
}

// route table association
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}

// security group
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "security group for http and ssh"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "allow http inbound"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "allow https inbound"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "allow ssh inbound"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// route53 hosted private zone
resource "aws_route53_zone" "privatezone" {
  name          = "atlas.local"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.vpc1.id
  }
  depends_on = [aws_vpc.vpc1]
}

// ec2 instance
resource "aws_instance" "vm1" {
  ami                    = "ami-0cbe318e714fc9a82"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  subnet_id              = aws_subnet.subnet1.id
  user_data              = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "Hi this is $HOSTNAME. you are f'ing awesome" >> /var/www/html/index.html
  EOF
  depends_on             = [aws_security_group.sg1]

  tags = {
    Name = "vm1"
  }
}

// route53 record
resource "aws_route53_record" "www" {
  zone_id    = aws_route53_zone.privatezone.id
  name       = "atlas.local"
  type       = "A"
  records    = [aws_instance.vm1.private_ip]
  ttl        = 300
  depends_on = [aws_instance.vm1]
}