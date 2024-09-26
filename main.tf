#creating vpc
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = var.dns_hostname
    tags =  merge (
        var.common_tags,
        var.vpc_tags,
    { 
        Name = local.resource_name
    }
    )
}

#creating internet gateway
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        var.ig_tags,
        {
            Name = local.resource_name
        }
    )
}

#creating public subnet
resource "aws_subnet" "public" {
    count = length(var.public_cidr_blocks)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_cidr_blocks[count.index]
    availability_zone =  local.az_zone[count.index]
    map_public_ip_on_launch = true
    tags = merge (
        var.common_tags,
        var.subnet_tags,
        {
            Name = "${local.resource_name} - public- ${local.az_zone[count.index]}"
        }
    )
}

#creating private subnet
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_zone[count.index]
    tags = merge(
        var.common_tags,
        var.subnet_tags,
        {
            Name = "${local.resource_name} - private - ${local.az_zone[count.index]}"
        }
    )

}

#creating database subnet
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_zone[count.index]
    tags = merge(
        var.common_tags,
        var.subnet_tags,
        {
            Name = "${local.resource_name} - database - ${local.az_zone[count.index]}"
        }
    )
}

resource "aws_db_subnet_group" "default" {
    name = local.resource_name
    subnet_ids = aws_subnet.database[*].id
    tags = merge (
        var.common_tags,
        var.subnet_tags,
        {
            Name = local.resource_name
        }
    )

}

#creating elastic ip
resource "aws_eip" "nat" {
    domain = "vpc"
}

#creating nat gateway
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id

    depends_on = [aws_internet_gateway.ig]
}

# creating route tables
resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.main.id
    tags = merge (
        var.common_tags,
        {
            Name = var.public_route_tags
        }
    )
}

resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        {
            Name = var.private_route_tags
        }
    )
}

resource "aws_route_table" "database_route" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        {
            Name = var.database_route_tags
        }
    )
}

#creating routes

resource "aws_route" "public" {
    route_table_id = aws_route_table.public_route.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private_route.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database_route.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
}

#creating associations

resource "aws_route_table_association" "public_association" {
    count = length(var.public_cidr_blocks)
    route_table_id = aws_route_table.public_route.id
    subnet_id = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "private_association" {
    count = length(var.private_subnet_cidrs)
    route_table_id = aws_route_table.private_route.id
    subnet_id = aws_subnet.private[count.index].id
}

resource "aws_route_table_association" "database_association" {
    count = length(var.database_subnet_cidrs)
    route_table_id = aws_route_table.database_route.id
    subnet_id = aws_subnet.database[count.index].id
}