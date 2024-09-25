variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "dns_hostname" {
    default = true
}

variable "project_name" {
    type = string

}

variable "environment" {
    type = string
}

variable "common_tags" {
    default = {
        project = "expense"
        environment ="dev"
    }
}

variable "vpc_tags" {
    default = {
        component = "vpc"
    }
}

variable "ig_tags" {
    default = {
        component = "internet gateway"
    }
}

variable "public_cidr_blocks" {
    type = list 
    validation {
        condition = length(var.public_cidr_blocks) == 2
        error_message = "provide 2 valid subnet id's"
    }
    
}

variable "private_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "provide 2 valid subnet id's"
    }
}

variable "subnet_tags" {
    default = {
        Name = "subnet"
    }
}
variable "database_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "provide 2 valid subnet id's"
    }
}

