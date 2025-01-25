output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet_1.id
}

# output "security_group_id" {
#   value = aws_security_group.allow_web.id
# }