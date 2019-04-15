# The playground VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.10.10.0/24"
  enable_dns_hostnames = true

  tags = "${merge(var.tags, map("Name", "Playground VPC"))}"
}

# Public subnet of the VPC
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.10.10.0/24"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  depends_on = [
    "aws_internet_gateway.playground_igw"
  ]

  tags = "${merge(var.tags, map("Name", "Playground Public Subnet"))}"
}

# Default route table
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags = "${merge(var.tags, map("Name", "Playground"))}"
}

# Route all external traffic through the internet gateway
resource "aws_route" "route_external_traffic_through_internet_gateway" {
  route_table_id = "${aws_default_route_table.default_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.playground_igw.id}"
}

# ACL for the public subnet of the VPC
resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.public.id}"
  ]

  tags = "${merge(var.tags, map("Name", "Playground Public Subnet ACL"))}"
}

# The internet gateway for the VPC
resource "aws_internet_gateway" "playground_igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, map("Name", "Playground IGW"))}"
}

# Private subnet of the VPC, for database and CyHy commander
resource "aws_subnet" "playground_private_subnet" {
 vpc_id = "${aws_vpc.vpc.id}"
 cidr_block = "10.10.10.0/25"
 availability_zone = "${var.aws_region}${var.aws_availability_zone}"

 depends_on = [
   "aws_internet_gateway.playground_igw"
 ]

 tags = "${merge(var.tags, map("Name", "Playground Private"))}"
}

# Public subnet of the VPC
#
# All traffic from private subnet will route through here
resource "aws_subnet" "playground_public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  # TODO: Maybe make this subnet smaller?
  cidr_block = "10.10.10.128/25"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  depends_on = [
    "aws_internet_gateway.playground_igw"
  ]

  tags = "${merge(var.tags, map("Name", "Playground Public"))}"
}

# ACL for the private subnet of the VPC
resource "aws_network_acl" "playground_private_acl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.playground_private_subnet.id}"
  ]

  tags = "${merge(var.tags, map("Name", "Playground Private Subnet ACL"))}"
}

# Security group for the private portion of the VPC
resource "aws_security_group" "playground_private_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, map("Name", "Playground Private"))}"
}

# Security group for the bastion host
resource "aws_security_group" "playground_bastion_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags, map("Name", "Playground Bastion"))}"
}
