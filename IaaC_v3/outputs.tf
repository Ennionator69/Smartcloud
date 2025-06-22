# Outputs für den Load Balancer entfernt, da dieser nicht mehr verwendet wird
output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = module.loadbalancer.public_ip_address
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.loadbalancer.dns_name
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN Gateway"
  value       = module.network.vpn_gateway_public_ip
}

output "vpn_client_configuration" {
  description = "VPN client configuration"
  value       = module.network.vpn_client_configuration
  sensitive   = true
}

output "vpn_client_certificate" {
  description = "Client certificate for VPN connection"
  value       = module.network.client_certificate
  sensitive   = true
}

output "vpn_client_private_key" {
  description = "Client private key for VPN connection"
  value       = module.network.client_private_key
  sensitive   = true
}

output "vpn_root_certificate" {
  description = "Root certificate for VPN connection"
  value       = module.network.root_certificate
  sensitive   = true
}

output "vm_private_ips" {
  description = "Private IP addresses of the VMs"
  value       = module.vm.private_ip_addresses
}

# Removed vm_public_ips output, as public_ip_addresses no longer exists in the vm module 