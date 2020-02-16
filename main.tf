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

resource "aws_security_group" "ha_public" {
  name        = "ha_public"
  description = "HA public security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ha_private" {
  name        = "ha_private"
  description = "HA private security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ha_public.id}"]
  }
}

resource "aws_instance" "ha-public" {
  ami = "ami-099a8245f5daa82bf"
  instance_type = "t2.micro"
  subnet_id = "${module.subnet.subnet-eu-west-1a-public.id}"
  vpc_security_group_ids = ["${aws_security_group.ha_public.id}"]
  key_name = "ireland2"

  tags = {
    Name = "HA public EC2 instance"
  }
}

resource "aws_instance" "ha-private" {
  ami = "ami-099a8245f5daa82bf"
  instance_type = "t2.micro"
  subnet_id = "${module.subnet.subnet-eu-west-1a-private.id}"
  vpc_security_group_ids = ["${aws_security_group.ha_private.id}"]
  key_name = "ireland2"

  tags = {
    Name = "HA private EC2 instance"
  }
}
