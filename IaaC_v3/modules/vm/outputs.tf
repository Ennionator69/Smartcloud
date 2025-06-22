output "vm_ids" {
  description = "IDs of the created VMs"
  value       = azurerm_linux_virtual_machine.main[*].id
}

output "nic_ids" {
  description = "List of network interface IDs"
  value       = azurerm_network_interface.main[*].id
}

output "private_ip_addresses" {
  description = "Private IP addresses of the VMs"
  value       = azurerm_network_interface.main[*].private_ip_address
} 