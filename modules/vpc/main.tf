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

# Security group
resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "ssh connection"
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

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-ssh", var.name)
  }))}"
}

resource "aws_security_group" "nat" {
  name = "nat_instance"
  description = "Allow private subnet outbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "nat"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = aws_subnet.private.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-nat", var.name)
  }))}"
}

# NAT instance
resource "aws_instance" "nat_instance" {
  ami                         = "ami-00295862c013bede0" // amzn-ami-vpc-nat
  instance_type               = "t3.micro"
  key_name                    = "secret"
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id               = aws_subnet.public.*.id[0]
  vpc_security_group_ids  = [aws_security_group.ssh.id, aws_security_group.nat.id]
  
  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-bastion", var.name)
  }))}"
}
