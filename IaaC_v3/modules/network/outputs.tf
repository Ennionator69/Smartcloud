output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vm_subnet_id" {
  description = "ID of the VM subnet"
  value       = azurerm_subnet.vm.id
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN Gateway"
  value       = azurerm_public_ip.gateway.ip_address
}

output "vpn_client_configuration" {
  description = "VPN client configuration"
  value       = azurerm_virtual_network_gateway.main.vpn_client_configuration
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for VPN connection"
  value       = local.client_cert_pem
  sensitive   = true
}

output "client_private_key" {
  description = "Client private key for VPN connection"
  value       = local.client_key_pem
  sensitive   = true
}

output "root_certificate" {
  description = "Root certificate for VPN connection"
  value       = local.root_cert_pem
  sensitive   = true
}

output "network_security_group_id" {
  description = "ID of the VM network security group"
  value       = azurerm_network_security_group.vm.id
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.main.id
} 