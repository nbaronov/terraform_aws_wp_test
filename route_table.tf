resource "aws_route_table" "infrastructure_route_table" {
  vpc_id = aws_vpc.infrastructure_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route_first_subnet_to_gw" {
  subnet_id      = aws_subnet.first_public_subnet.id
  route_table_id = aws_route_table.infrastructure_route_table.id
}

resource "aws_route_table_association" "route_second_subnet_to_gw" {
  subnet_id      = aws_subnet.second_public_subnet.id
  route_table_id = aws_route_table.infrastructure_route_table.id
}

resource "aws_route_table_association" "route_db_subnet_to_gw" {
  subnet_id      = aws_subnet.db_public_subnet.id
  route_table_id = aws_route_table.infrastructure_route_table.id
}
