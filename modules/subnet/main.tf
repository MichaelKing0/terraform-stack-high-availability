variable "vpc_id" {
  type = "string"
}

resource "aws_subnet" "eu-west-1a-public" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "1a public"
  }
}

resource "aws_subnet" "eu-west-1a-private" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "1a private"
  }
}

resource "aws_subnet" "eu-west-1b-public" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "1b public"
  }
}

resource "aws_subnet" "eu-west-1b-private" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "1b private"
  }
}

output "subnet-eu-west-1a-public" {
  value = "${aws_subnet.eu-west-1a-public}"
}

output "subnet-eu-west-1a-private" {
  value = "${aws_subnet.eu-west-1a-private}"
}

output "subnet-eu-west-1b-public" {
  value = "${aws_subnet.eu-west-1b-public}"
}

output "subnet-eu-west-1b-private" {
  value = "${aws_subnet.eu-west-1b-private}"
}