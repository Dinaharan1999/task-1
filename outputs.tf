output "load_balancer_dns" {
  description = "Public DNS of the load balancer"
  value       = aws_lb.task_lb.dns_name
}

output "instance_1_public_ip" {
  description = "Public IP of task-instance-1"
  value       = aws_instance.web[0].public_ip
}

output "instance_2_public_ip" {
  description = "Public IP of task-instance-2"
  value       = aws_instance.web[1].public_ip
}