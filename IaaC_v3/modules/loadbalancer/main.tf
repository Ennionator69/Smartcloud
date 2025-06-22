resource "azurerm_public_ip" "lb" {
  name                = "${lower(var.project_name)}-lb-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "main" {
  name                = "${lower(var.project_name)}-lb"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${lower(var.project_name)}-backend-pool"
  loadbalancer_id = azurerm_lb.main.id

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Wait for the backend pool to be fully provisioned
resource "time_sleep" "wait_for_backend_pool" {
  depends_on = [azurerm_lb_backend_address_pool.main]
  create_duration = "30s"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = length(var.vm_nic_ids)
  network_interface_id    = var.vm_nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id

  depends_on = [
    time_sleep.wait_for_backend_pool
  ]

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# Add outbound rule for internet access
resource "azurerm_lb_outbound_rule" "internet" {
  name                     = "${lower(var.project_name)}-outbound-rule"
  loadbalancer_id          = azurerm_lb.main.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.main.id
  
  frontend_ip_configuration {
    name = "frontend-ip"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "azurerm_lb_probe" "http" {
  name            = "${lower(var.project_name)}-http-probe"
  loadbalancer_id = azurerm_lb.main.id
  protocol        = "Tcp"
  port            = 8080
  interval_in_seconds = 5
  number_of_probes    = 2

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "azurerm_lb_rule" "http" {
  name                           = "${lower(var.project_name)}-http-rule"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = true
  load_distribution              = "Default"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "azurerm_lb_rule" "https" {
  name                           = "${lower(var.project_name)}-https-rule"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 8443
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = true
  load_distribution              = "Default"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "azurerm_lb_rule" "bitwarden" {
  name                           = "${lower(var.project_name)}-bitwarden-rule"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = "Tcp"
  frontend_port                  = 8081
  backend_port                   = 8081
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = true
  load_distribution              = "Default"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "azurerm_lb_rule" "stirling" {
  name                           = "${lower(var.project_name)}-stirling-rule"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = "Tcp"
  frontend_port                  = 8082
  backend_port                   = 8082
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = true
  load_distribution              = "Default"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
} 