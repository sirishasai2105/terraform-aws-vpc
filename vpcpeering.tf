resource "aws_vpc_peering_connection" "vpc_peer" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id #acceptor id
  vpc_id        = aws_vpc.main.id # requestor id
  auto_accept = true
  tags = {
    Name = "peering - vpc"
  }
}

resource "aws_route" "public_peering" {
  route_table_id            = aws_route_table.public_route.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer[0].id
}

resource "aws_route" "private_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id = aws_route_table.private_route.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer[0].id
}

resource "aws_route" "default_peering" {
    count = var.is_peering_required ? 1 : 0
    destination_cidr_block = aws_vpc.main.cidr_block
    route_table_id = data.aws_vpc.default.main_route_table_id
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer[0].id
}