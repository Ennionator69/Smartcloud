resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  vpn_address_space  = var.vpn_address_space
  vpn_sku           = var.vpn_sku
  tags              = var.tags
}

module "vm" {
  source = "./modules/vm"

  project_name       = var.project_name
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.network.vm_subnet_id
  network_security_group_id = module.network.network_security_group_id
  vm_count           = var.vm_count
  vm_size            = var.vm_size
  admin_username     = var.admin_username
  admin_password     = var.admin_password
  tags              = var.tags
  
  depends_on = [
    module.network
  ]
}

# Load balancer module - uncommented and updated
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name       = var.project_name
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  vm_nic_ids         = module.vm.nic_ids
  tags              = var.tags
  
  depends_on = [
    module.vm
  ]
}

module "security" {
  source = "./modules/security"

  project_name       = var.project_name
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.network.vm_subnet_id
  tags              = var.tags
  
  depends_on = [
    module.network
  ]
}

# Diese leere Ressource dient nur dazu, sicherzustellen, dass das VPN Gateway als letztes erstellt wird
resource "null_resource" "vpn_gateway_depends_on" {
  depends_on = [
    module.vm,
    module.security,
    module.loadbalancer
  ]
  
  triggers = {
    network_module = module.network.vpn_gateway_id
  }
} 