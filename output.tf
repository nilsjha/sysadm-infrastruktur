output "ec2_instance_ids" {
  description = "EC2-identifier for the webservers (*) = a list"
  value       = aws_instance.webserver.*.id
}

output "ec2_instance_ips" {
  description = "IP-address of the webservers"
  value       = aws_instance.webserver.*.public_ip
}

output "elb_public_dns_host" {
  description = "DNS-host for the load balancer"
  value       = aws_elb.lb_web.dns_name
}

output "ec2_access_mgmt_pubkey" {
  description = "Pubkey to use for mgmt access"
  value       = tls_private_key.key.public_key_openssh
}

output "ec2_access_mgmt_privkey" {
  description = "Key to use for mgmt access"
  value       = tls_private_key.key.private_key_pem
}

output "ec2_instance_type" {
    description = "Used for test"
    value = aws_instance.webserver.*.instance_type
}