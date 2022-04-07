output vpc_id {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output public_subnet_ids {
  value       = aws_subnet.public.*.id
  description = "Public subnet id list"
}

output private_subnet_ids {
  value       = aws_subnet.private.*.id
  description = "Private subnet id list"
}

output key_name {
  value       = aws_key_pair.secret.key_name
  description = "Key name for aws instance"
}

output ssh_sg_id {
  value       = aws_security_group.ssh.id
  description = "ssh security group id"
}