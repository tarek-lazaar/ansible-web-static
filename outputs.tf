output "ip_address" {
  description = "Ip address of ec2 instance"
  value       = aws_instance.my-instance.public_ip
}