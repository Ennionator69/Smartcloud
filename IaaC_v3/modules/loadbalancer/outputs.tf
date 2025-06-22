output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "dns_name" {
  description = "DNS name of the load balancer"
  value       = azurerm_public_ip.lb.fqdn
}

output "backend_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
} 