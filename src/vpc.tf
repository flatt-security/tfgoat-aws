resource "aws_vpc" "tfgoat" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "tfgoat" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.tfgoat.id
}

resource "aws_internet_gateway" "tfgoat" {
  vpc_id = aws_vpc.tfgoat.id
}

resource "aws_route_table" "tfgoat" {
  vpc_id = aws_vpc.tfgoat.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfgoat.id
  }
}

resource "aws_route_table_association" "tfgoat" {
  count = 2

  subnet_id      = aws_subnet.tfgoat.*.id[count.index]
  route_table_id = aws_route_table.tfgoat.id
}
