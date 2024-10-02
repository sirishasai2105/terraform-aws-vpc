output "vpc_id" {
    value = aws_vpc.main.id
}

output "az_zone" {
    value = data.aws_availability_zones.available
}

output "default_info" {
    value = data.aws_vpc.default
}

output "subnet_ids" {
    value = aws_subnet.public[*].id
}

output "backend_subnet_id" {
    value = aws_subnet.private[*].id
}

output "database_subnet_id" {
    value = aws_subnet.database[*].id
}

output "db_subnet_group" {
    value = aws_db_subnet_group.default.name
}