output "wp_node1_instance_ip" {
  value = aws_instance.wp_node1_instance.public_ip
}

output "wp_node2_instance_ip" {
  value = aws_instance.wp_node2_instance.public_ip
}

output "db_instance_ip" {
  value = aws_instance.db_instance.public_ip
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.application_loadbalancer.dns_name
}
