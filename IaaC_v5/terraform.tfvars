project_name = "SmartCloud"
location     = "East US"
environment  = "prod"
vm_count     = 2
vm_size      = "Standard_D2s_v3"
admin_username = ""
admin_password   = ""
vpn_address_space = "10.2.0.0/24"
vpn_sku          = "VpnGw1"

tags = {
  Project     = "SmartCloud"
  Environment = "Production"
  ManagedBy   = "Terraform"
} 