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
