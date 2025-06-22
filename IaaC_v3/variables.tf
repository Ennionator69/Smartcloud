variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "SmartCloud"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment (e.g. dev, prod)"
  type        = string
  default     = "prod"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
}

variable "vpn_address_space" {
  description = "Address space for VPN clients"
  type        = string
  default     = "10.2.0.0/24"
}

variable "vpn_sku" {
  description = "SKU for the VPN Gateway"
  type        = string
  default     = "VpnGw1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SmartCloud"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
} 