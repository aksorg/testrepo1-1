variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "RG location in Azure"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault name in Azure"
}

variable "sku_name" {
  type        = string
  default     = "standard"
}

variable "enabled_for_disk_encryption" {
  type       = bool
  default    = false
}

variable "enabled_for_deployment" {
  type       = bool
  default    = false
}

variable "enabled_for_template_deployment" {
  type       = bool
  default    = false
}

variable "enable_rbac_authorization" {
  type       = bool
  default    = false
}

variable "purge_protection_enabled" {
  type       = bool
  default    = false
}

variable "key_permissions"{
  type     = list(string)
}

variable "secret_permissions"{
  type     = list(string)
}

variable "storage_permissions"{
  type     = list(string)
}

variable "default_action" {
  type        = string
}

variable "bypass" {
  type        = string
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
}
 
variable "soft_delete_retention_days" {
    type      = number
}