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