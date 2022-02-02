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
# Configure the Microsoft Azure Provider
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

data "azurerm_resources" "vnet_rg" {
  count = length(var.vnet_rg) > 0 ? 0 : 1
  type  = "Microsoft.Network/virtualNetworks"
  name  = var.vnet_name
}

locals {
  acr_id         = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.appservice_rg}/providers/Microsoft.ContainerRegistry/registries/${local.acr_name}"
  app_service_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.appservice_rg}/providers/Microsoft.Web/sites/${local.app_service_name}"
  keyvault_id    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.appservice_rg}/providers/Microsoft.KeyVault/vaults/${local.keyvault_name}"

  resource_name_prefix = "${module.portfolio.portfolio_code}${var.environment_name}${module.regions.location_short}${substr(var.application_name, 0, 6)}"
  appservice_rg        = length(var.appservice_rg) > 0 ? var.appservice_rg : "${module.portfolio.portfolio_code}-${var.environment_name}-${module.regions.location_short}-${substr(var.application_name, 0, 6)}-rg-01"
  acr_name             = length(var.acr_name) > 0 ? var.acr_name : "${local.resource_name_prefix}acr01"
  app_service_name     = length(var.app_service_name) > 0 ? var.app_service_name : "${local.resource_name_prefix}app01"
  keyvault_name        = length(var.keyvault_name) > 0 ? var.keyvault_name : "${local.resource_name_prefix}kv01"

  #subnet_ids        = [data.azurerm_subnet.subnet.id, data.azurerm_subnet.subnet2.id]
  resource_id_list  = length(local.keyvault_name) > 0 ? [local.app_service_id, local.acr_id, local.keyvault_id] : [local.app_service_id, local.acr_id]
  subresource_names = ["sites", "registry", "vault"]
  private_endpoints = ["app01_pe", "acr01_pe", "kv01_pe"]
  fqdns             = [1, 2, 1]
  # private_endpoints = ["${substr(var.app_service_name, -2, -1)}_pe", "${substr(var.acr_name, -2, -1)}_pe", "${substr(var.keyvault_name, -2, -1)}_pe"]
  #nsg_name          = "${local.resource_name_prefix}nsg01"
  vnet_rg = length(var.vnet_rg) > 0 ? var.vnet_rg : split("/", data.azurerm_resources.vnet_rg[0].resources.0.id)[4]
}


data "azurerm_client_config" "main" {}

data "azurerm_subnet" "subnet" {
  name                 = var.vnet_integration_subnet
  virtual_network_name = var.vnet_name
  resource_group_name  = local.vnet_rg
}

# data "azurerm_subnet" "subnet2" {
#   name                 = var.appgw_subnet
#   virtual_network_name = var.vnet_name
#   resource_group_name  = local.vnet_rg
# }

data "azurerm_subscription" "current" {
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetint" {
  app_service_id = local.app_service_id
  subnet_id      = data.azurerm_subnet.subnet.id
}

module "private_endpoint" {
  count                          = length(local.resource_id_list)
  source                         = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/private_endpoint?ref=terraform-modules"
  private_connection_resource_id = local.resource_id_list[count.index]
  subresource_names              = local.subresource_names[count.index]
  private_endpoint_name          = local.private_endpoints[count.index]
  vnet_resource_group_name       = local.vnet_rg
  resource_group_name            = local.appservice_rg
  vnet_name                      = var.vnet_name
  private_end_point_subnet       = var.private_end_point_subnet
  fqdns                          = local.fqdns[count.index]
}
# module "network_security_group" {
#   source                = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/nsg?ref=terraform-modules"
#   create_resource_group = false
#   resource_group_name   = var.appservice_rg
#   location              = module.regions.location_cli
#   nsg_name              = local.nsg_name
#   nsg_rules             = var.nsg_rules
# }

# resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#   count                     = length(local.subnet_ids)
#   subnet_id                 = local.subnet_ids[count.index]
#   network_security_group_id = module.network_security_group.nsg_id
# }