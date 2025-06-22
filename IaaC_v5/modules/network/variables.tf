variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vpn_address_space" {
  description = "Address space for VPN clients"
  type        = string
}

variable "vpn_sku" {
  description = "SKU for the VPN Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
} 