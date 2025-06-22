resource "azurerm_virtual_network" "main" {
  name                = "${lower(var.project_name)}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "vm" {
  name                = "${lower(var.project_name)}-vm-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-bitwarden"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-stirling"
    priority                   = 107
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8082"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
  
  depends_on = [
    azurerm_subnet.vm,
    azurerm_network_security_group.vm
  ]
}

resource "azurerm_public_ip" "gateway" {
  name                = "${lower(var.project_name)}-vpn-gateway-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = var.tags
}

# Generate root certificate
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "SmartCloud VPN Root CA"
    organization = "SmartCloud"
  }

  validity_period_hours = 8760 # 1 year
  is_ca_certificate    = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# Generate client certificate
resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "SmartCloud VPN Client"
    organization = "SmartCloud"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "client_auth",
  ]
}

locals {
  root_cert_pem = base64encode(tls_self_signed_cert.root.cert_pem)
  client_cert_pem = base64encode(tls_locally_signed_cert.client.cert_pem)
  client_key_pem  = base64encode(tls_private_key.client.private_key_pem)
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "${lower(var.project_name)}-vpn-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "Basic"
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "vpnGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  vpn_client_configuration {
    address_space = [var.vpn_address_space]
    vpn_auth_types = ["Certificate"]
    
    root_certificate {
      name             = "SmartCloud-Root-Cert"
      public_cert_data = local.root_cert_pem
    }
  }

  tags = var.tags

  # VPN Gateway soll als letztes erstellt werden
  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.gateway,
    azurerm_public_ip.gateway,
    azurerm_subnet.vm,
    azurerm_network_security_group.vm,
    azurerm_subnet_network_security_group_association.vm
  ]

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
} 