output "app_url" {
  description = "Public URL of the student records app"
  value       = "http://${aws_instance.app.public_ip}"
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/is311-lab-key.pem ubuntu@${aws_instance.app.public_ip}"
}
