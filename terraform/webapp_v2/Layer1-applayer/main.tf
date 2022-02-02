
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.5.0" // provide appriate version required for this module
    }
    infoblox = {
      source  = "infobloxopen/infoblox"
      version = "2.0.1"
    }
  }
}
provider "infoblox" {
  username = var.username
  password = var.password
  server   = var.host
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "regions" {
  source       = "claranet/regions/azurerm"
  version      = "4.2.0"
  azure_region = var.location
}

module "portfolio" {
  source         = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/portfolio_mapping?ref=terraform-modules"
  portfolio_name = var.portfolio
  region         = module.regions.location_cli
  environment    = "Nonprod"
}

# resource "random_string" "random" {
#   length      = 2
#   min_numeric = 2
# }


#------------------------
# Local declarations
#------------------------

locals {
  resource_name_prefix  = "${module.portfolio.portfolio_code}${var.environment_name}${module.regions.location_short}${substr(var.application_name, 0, 6)}"
  resource_group_name   = "${module.portfolio.portfolio_code}-${var.environment_name}-${module.regions.location_short}-${substr(var.application_name, 0, 6)}-rg-01"
  webappName            = "${local.resource_name_prefix}app01"
  acr_name              = var.create_container ? "${local.resource_name_prefix}acr01" : var.container_name
  app_service_plan_name = var.create_app_service_plan ? "${local.resource_name_prefix}-asp-01" : var.app_service_plan_name
  keyvault_name         = "${local.resource_name_prefix}kv01"
  tags = merge(var.tags, {
    ApplicationName = var.application_name
  })

  app_settings = merge({ WEBSITE_VNET_ROUTE_ALL = true }, var.app_settings)

}

resource "azurerm_resource_group" "rg" {
  count    = length(var.resource_group_name) > 0 ? 0 : 1
  name     = local.resource_group_name
  location = module.regions.location_cli
}

module "webapp_container" {
  source                  = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/webapp_container?ref=terraform-modules"
  webappName              = local.webappName
  application_name        = var.application_name
  location                = module.regions.location_cli
  resource_group_name     = length(var.resource_group_name) > 0 ? var.resource_group_name : azurerm_resource_group.rg[0].name
  create_app_service_plan = var.create_app_service_plan
  create_container        = true
  container_sku           = var.container_sku
  container_name          = local.acr_name
  app_service_plan_name   = local.app_service_plan_name
  os_type                 = var.os_type
  plan                    = var.plan
  app_service_plan_id     = var.create_app_service_plan ? null : var.app_service_plan_id
  app_settings            = local.app_settings
  secure_app_settings     = var.secure_app_settings
  client_affinity_enabled = var.client_affinity_enabled
  https_only              = var.https_only
  # vnet_integration        = var.vnet_integration
  # subnet_name             = "${local.webappName}_int_subnet"
  # virtual_network_name    = var.virtual_network_name
  # address_prefixes        = var.address_prefixes
}

module "Key_vault" {
  count                           = var.create_key_vault ? 1 : 0
  source                          = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/Keyvault?ref=terraform-modules"
  create_resource_group           = false
  resource_group_name             = length(var.resource_group_name) > 0 ? var.resource_group_name : azurerm_resource_group.rg[0].name
  location                        = module.regions.location_cli
  keyvault_name                   = local.keyvault_name
  sku_name                        = var.keyvault_sku_name
  enabled_for_disk_encryption     = var.kv_enabled_for_disk_encryption
  enabled_for_deployment          = var.kv_enabled_for_deployment
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment
  enable_rbac_authorization       = var.kv_enable_rbac_authorization
  soft_delete_retention_days      = var.kv_soft_delete_retention_days
  purge_protection_enabled        = var.kv_purge_protection_enabled
  default_action                  = var.kv_default_action
  ip_rules                        = var.kv_ip_rules
  virtual_network_subnet_ids      = var.kv_virtual_network_subnet_ids
  key_permissions                 = var.kv_key_permissions
  secret_permissions              = var.kv_secret_permissions
  storage_permissions             = var.kv_storage_permissions
  object_id                       = var.kv_object_id
  create_keyvault_secret          = var.create_keyvault_secret
  secret_list                     = var.kv_secret_list

}
