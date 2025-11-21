resource "aws_vpc" "infrastructure_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.infrastructure_vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "first_public_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidr[0]
  availability_zone       = var.wp_nodes_availability_zone[0]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "First Public Subnet"
  }
}

resource "aws_subnet" "second_public_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidr[1]
  availability_zone       = var.wp_nodes_availability_zone[1]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Second Public Subnet"
  }
}

resource "aws_subnet" "db_public_subnet" {
  vpc_id                  = aws_vpc.infrastructure_vpc.id
  cidr_block              = var.subnet_cidr[2]
  availability_zone       = var.db_node_availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name = "DB Public Subnet"
  }
}

variable "inbound_ports_production" {
  type        = list(any)
  default     = [22, 80]
  description = "Inbound ports"
}
