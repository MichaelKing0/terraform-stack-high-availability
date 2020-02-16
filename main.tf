provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "HA VPC"
  }
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "HA IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "HA Public Route Table"
  }
}

resource "aws_route_table_association" "eu-west-1a-public" {
  subnet_id = "${module.subnet.subnet-eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "eu-west-1b-public" {
  subnet_id = "${module.subnet.subnet-eu-west-1b-public.id}"
  route_table_id = "${aws_route_table.public.id}"
}