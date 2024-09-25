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

resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id

    depends_on = [aws_internet_gateway.ig]
}
