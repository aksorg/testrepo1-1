provider "azurerm" {
  features {}
}

module "regions" {
  source       = "claranet/regions/azurerm"
  version      = "4.2.0"
  azure_region = var.location
}

module "portfolio" {
  source         = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/portfolio-names?ref=terraform-modules"
  portfolio_name = var.portfolio
}

#------------------------
# Local declarations
#------------------------

locals {
  resource_name_prefix  = "${module.portfolio.portfolio_code}${var.environment_name}${module.regions.location_short}${substr(var.application_name, 0, 6)}"
  resource_group_name   = "${module.portfolio.portfolio_code}-${var.environment_name}-${module.regions.location_short}-${substr(var.application_name, 0, 6)}-rg-01"
  webappName            = "${local.resource_name_prefix}app01"
  acr_name              = var.create_container ? "${local.resource_name_prefix}acr01" : var.container_name
  app_service_plan_name = var.create_app_service_plan ?"${local.resource_name_prefix}-asp-01" : var.app_service_plan_name

  tags = merge(var.tags, {
    ApplicationName = var.application_name
  })

}

resource "azurerm_resource_group" "rg" {
  
  name     = local.resource_group_name
  location = module.regions.location_cli
}

module "webapp_container" {
  source                  = "git::https://github.com/DigitalInnovation/cloud-platform-automation-assets.git//modules/webapp_container?ref=akshai_terraform"
  webappName              = local.webappName
  application_name        = var.application_name
  location                = module.regions.location_cli
  resource_group_name     = local.resource_group_name
  create_app_service_plan = var.create_app_service_plan
  create_container        = var.create_container
  container_name          = local.acr_name
  app_service_plan_name   = local.app_service_plan_name
  os_type                 = var.os_type
  vnet_route_all_enabled  = var.vnet_route_all_enabled
  container_sku           = var.container_sku
}