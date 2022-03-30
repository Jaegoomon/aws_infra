# VPC
resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s", var.name)
  }))}"
}

# Internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id  = aws_vpc.this.id

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s", var.name)
  }))}"
}

# Subnets
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id            = aws_vpc.this.id
  cidr_block        = "${var.public_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-public-%s", var.name, var.azs[count.index])
  }))}"
}

resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id            = aws_vpc.this.id
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-private-%s", var.name, var.azs[count.index])
  }))}"
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-public", var.name)
  }))}"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance.id
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-private", var.name)
  }))}"
}

# Route table associations
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id       = aws_subnet.public.*.id[count.index]
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id       = aws_subnet.private.*.id[count.index]
  route_table_id  = aws_route_table.private.id
}
