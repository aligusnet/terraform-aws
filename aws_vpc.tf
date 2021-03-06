resource "aws_vpc" "main" {
    cidr_block = "10.42.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
    tags = {
        Name = "voting-vpc"
    }
}

resource "aws_subnet" "private" {
    cidr_block = "10.42.0.0/24"
    vpc_id = aws_vpc.main.id
    availability_zone = "${var.region}b"
    tags = {
        Name = "voting-subnet-private"
    }
}

resource "aws_subnet" "public" {
    cidr_block = "10.42.1.0/24"
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = true
    availability_zone = "${var.region}a"
    tags = {
        Name = "voting-subnet-public"
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}
