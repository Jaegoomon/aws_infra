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
    cidr_block = local.all_ip
    gateway_id = aws_internet_gateway.this.id
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-public", var.name)
  }))}"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block  = local.all_ip
    instance_id = aws_instance.nat.id
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
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-ssh", var.name)
  }))}"
}

resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow private subnet outbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "nat"
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = aws_subnet.private.*.cidr_block
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }

  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-nat", var.name)
  }))}"
}

# Key pair
resource "aws_key_pair" "nat" {
  key_name   = "${var.key_name}"
  public_key = "${var.key_file}"
}

# NAT instance
resource "aws_instance" "nat" {
  ami                         = "ami-00295862c013bede0" // amzn-ami-vpc-nat
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.nat.key_name
  associate_public_ip_address = true
  source_dest_check           = false

  subnet_id               = aws_subnet.public.*.id[0]
  vpc_security_group_ids  = [aws_security_group.ssh.id, aws_security_group.nat.id]
  
  tags = "${merge(var.tags, tomap({
    "Name" = format("%s-bastion", var.name)
  }))}"
}
