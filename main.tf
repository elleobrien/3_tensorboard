provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "us-east-1a-public" {
  vpc_id = "${aws_vpc.example.id}"
  cidr_block = "10.0.1.0/25"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "ingress-all-test" {
  name = "allow-all-sg"
  vpc_id = "${aws_vpc.example.id}"
  ingress {
    cidr_blocks = [
        "0.0.0.0/0"
      ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip-example" {
  instance = "${aws_instance.example.id}"
  vpc = true
}

  //gateways.tf
resource "aws_internet_gateway" "example-gw" {
  vpc_id = "${aws_vpc.example.id}"
}

//subnets.tf
resource "aws_route_table" "route-table-example" {
  vpc_id = "${aws_vpc.example.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example-gw.id}"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id = "${aws_subnet.us-east-1a-public.id}"
  route_table_id = "${aws_route_table.route-table-example.id}"
}

resource "aws_instance" "example" {
  ami = "ami-2757f631"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.us-east-1a-public.id}"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
}
