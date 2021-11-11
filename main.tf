provider "azurerm" {
  features {}
} 

locals {
  fqdns   =[]
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.acrResourceGroup
  location = var.acrLocation
}

resource "azurerm_container_registry" "acr" {
  name                = var.acrName
  resource_group_name = var.acrResourceGroup
  location            = var.acrLocation
  sku                 = "Premium"
  admin_enabled       = false
  dynamic "georeplications" {
  for_each = var.georeplications
  content {
    location = georeplications.value.location
    zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
  }
}




  network_rule_set {
    default_action = "Deny" 
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "" {
  name                = "example-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id
  private_service_connection {
      name                              = "example-privateserviceconnection"
      is_manual_connection              = true
      private_connection_resource_id    = merge("/subscriptions/",var.acrSubscription,"/resourceGroups/",var.acrResourceGroup,"/providers/Microsoft.ContainerRegistry/registries/",var.acrName)
      subresource_names                 = ["registry"]
  }
  dynamic "custom_dns_configs" {
    for_each = local.fqdns
    content{
      fqdn = local.fqdns
    }
  }
}