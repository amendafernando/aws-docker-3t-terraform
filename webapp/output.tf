output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

# output "security_group_id" {
#   value = aws_security_group.allow_web.id
# }