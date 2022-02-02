
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

data "azurerm_resources" "vnet_rg" {
  count = length(var.appgw_vnet_resource_group_name) > 0 ? 0 : 1
  type  = "Microsoft.Network/virtualNetworks"
  name  = var.appgw_virtual_network_name
}

data "azurerm_resources" "kv_rg" {
  count = length(var.keyvault_rg) > 0 && var.keyvault_name == "" ? 0 : 1
  type  = "Microsoft.KeyVault/vaults"
  name  = var.keyvault_name
}


locals {
  resource_name_prefix     = "${module.portfolio.portfolio_code}${var.environment_name}${module.regions.location_short}${substr(var.application_name, 0, 6)}"
  keyvault_name            = "${local.resource_name_prefix}kv03"
  app_gateway              = "${local.resource_name_prefix}appgw01"
  app_service_name         = length(var.app_service_name) > 0 ? var.app_service_name : "${local.resource_name_prefix}app01"
  resource_group_name      = length(var.resource_group_name) > 0 ? var.resource_group_name : "${module.portfolio.portfolio_code}-${var.environment_name}-${module.regions.location_short}-${substr(var.application_name, 0, 6)}-rg-01"
  vnet_resource_group_name = length(var.appgw_vnet_resource_group_name) > 0 ? var.appgw_vnet_resource_group_name : split("/", data.azurerm_resources.vnet_rg[0].resources.0.id)[4]
  keyvault_rg              = length(var.keyvault_rg) > 0 ? var.keyvault_rg : split("/", data.azurerm_resources.kv_rg[0].resources.0.id)[4]

  frontendIP_config_name = "${local.app_gateway}_IpConfig"
  gateway_subnet_name    = "${local.app_service_name}_gwsubnet"
  backend_address_pool_list = [{
    name       = "${local.app_service_name}_WebApp"
    fqdns      = ["${local.app_service_name}.azurewebsites.net"]
    ip_address = []
  }]
  frontend_port_list = [{
    name = "${local.app_service_name}_port"
    port = 443
  }]
  http_listener_list = [{
    name               = "${local.app_service_name}_httpslistener"
    frontend_port_name = "${local.app_service_name}_port"
    protocol           = "https"
  }]
  request_routing_rule_list = [{
    name                       = "${local.app_service_name}_routingrule"
    http_listener_name         = "${local.app_service_name}_httpslistener"
    backend_http_settings_name = "${local.app_service_name}_backend_http"
    backend_address_pool_name  = "${local.app_service_name}_WebApp"
  }]
  backend_http_settings_list = [{
    name            = "${local.app_service_name}_backend_http"
    port            = 443
    protocol        = "https"
    request_timeout = 20
    probe_name      = "${local.app_service_name}_probe_443"
  }]
  health_probe_list = [{
    pick_host_name_from_backend_http_settings = true
    name                                      = "${local.app_service_name}_probe_443"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    protocol                                  = "https"
  }]

  kv_secret_list = ({
    "secret-for-certificate-name" = var.kv_secret_certificate_data
    "secret-for-certificate-pass" = var.kv_secret_certificate_pass
  })
}

data "azurerm_subscription" "current" {
}

module "Key_vault" {
  count                           = length(var.keyvault_name) > 0 ? 0 : 1
  source                          = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/Keyvault?ref=terraform-modules"
  create_resource_group           = false
  resource_group_name             = local.resource_group_name
  location                        = module.regions.location_cli
  keyvault_name                   = local.keyvault_name
  sku_name                        = var.kv_sku_name
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = false
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  default_action                  = "Deny"
  ip_rules                        = var.kv_ip_rules
  virtual_network_subnet_ids      = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.vnet_resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.appgw_virtual_network_name}/subnets/${var.gateway_subnet_name != "" ? var.gateway_subnet_name : local.gateway_subnet_name}", "/subscriptions/b2b4796f-452c-485f-9efd-d8b45b566e17/resourceGroups/cor-eun-prod-pltshrtools-rg-0001/providers/Microsoft.Network/virtualNetworks/cor-eun-prod-pltshrtools-mastr-vnet-0001/subnets/shsrv-eun-prod-cicd0001-aks-subnet-0001", "/subscriptions/b2b4796f-452c-485f-9efd-d8b45b566e17/resourceGroups/cor-eun-prod-pltshrtools-rg-0001/providers/Microsoft.Network/virtualNetworks/cor-eun-prod-pltshrtools-mastr-vnet-0001/subnets/shsrv-eun-prod-cicd01-aks-snet-0002"]
  secret_permissions              = var.kv_secret_permissions
  object_id                       = var.kv_object_id
  create_keyvault_secret          = true
  secret_list                     = local.kv_secret_list


}

data "azurerm_key_vault" "keyvault" {
  count               = length(var.keyvault_name) > 0 ? 1 : 0
  name                = var.keyvault_name
  resource_group_name = local.keyvault_rg
}


module "appgateway" {
  source                         = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/Application_Gateway?ref=terraform-modules"
  location                       = module.regions.location_cli
  appgw_resource_group_name      = local.resource_group_name
  application_gateway_name       = local.app_gateway
  frontendIP_config_name         = local.frontendIP_config_name
  gateway_tier_name              = var.gateway_tier_name
  gateway_tier                   = var.gateway_tier
  private_ip_address_allocation  = var.private_ip_address_allocation
  static_private_ip              = var.static_private_ip
  capacity                       = var.capacity
  create_subnet                  = false
  appgw_vnet_resource_group_name = local.vnet_resource_group_name
  appgw_virtual_network_name     = var.appgw_virtual_network_name
  #backend_ip_address             = var.backend_ip_address
  gateway_subnet_name = var.gateway_subnet_name != "" ? var.gateway_subnet_name : local.gateway_subnet_name
  address_prefixes    = var.address_prefixes

  secret_certificate_data     = var.keyvault_name != "" ? var.kv_secret_certificate_data_name : keys(local.kv_secret_list)[0]
  secret_certificate_password = var.keyvault_name != "" ? var.kv_secret_certificate_pass_name : keys(local.kv_secret_list)[1]


  keyvault_name = var.keyvault_name == "" ? local.keyvault_name : var.keyvault_name
  keyvault_rg   = var.keyvault_name == "" ? local.resource_group_name : local.keyvault_rg

  backend_address_pool_list  = length(var.backend_address_pool_list) > 0 ? concat(var.backend_address_pool_list, local.backend_address_pool_list) : local.backend_address_pool_list
  frontend_port_list         = length(var.frontend_port_list) > 0 ? concat(var.frontend_port_list, local.frontend_port_list) : local.frontend_port_list
  backend_http_settings_list = length(var.backend_http_settings_list) > 0 ? concat(var.backend_http_settings_list, local.backend_http_settings_list) : local.backend_http_settings_list
  request_routing_rule_list  = length(var.request_routing_rule_list) > 0 ? concat(var.request_routing_rule_list, local.request_routing_rule_list) : local.request_routing_rule_list
  http_listener_list         = length(var.http_listener_list) > 0 ? concat(var.http_listener_list, local.http_listener_list) : local.http_listener_list
  health_probe_list          = length(var.health_probe_list) > 0 ? concat(var.health_probe_list, local.health_probe_list) : local.health_probe_list
  clientid                   = var.clientid
  clientpass                 = var.clientpass
  tenant                     = var.tenant
  subscription               = var.subscription
  fqdn                       = var.fqdn
  depends_on = [
    module.Key_vault
  ]
}
