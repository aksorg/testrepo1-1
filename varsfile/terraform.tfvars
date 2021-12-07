#Resource details
# application_gateway_create = false
# rg-location                = "northeurope"
# enable_resource_group      = true
appgw_resource_group_name  = "demo"
application_gateway_name   = "sampleGW"
frontendIP_config_name     = "FrontIPConfigName"

#Sku 
gateway_tier_name = "WAF_Large"
gateway_tier      = "WAF"
capacity          = 2

#Vnet Details
appgw_vnet_resource_group_name = "vnet-rg"
appgw_virtual_network_name     = "sample-vnet"
gateway_subnet_name            = "subnt4"

#Frontend private ip allocation
private_ip_address_allocation = "Dynamic"
static_private_ip             = "10.1.0.7"

#backend pool IP
backend_ip_address = ["182.0.0.0", "172.1.1.1"]

#Keyvault ID
# appgw_keyvault_id = "/subscriptions/029910ea-8f05-405d-a05d-c5550d1d02c0/resourceGroups/vnet-rg/providers/Microsoft.KeyVault/vaults/samp-kv12"


#Vault secret for certificate and password 


#Rules to be defined as map
rules = [
  {
    rule_name                  = "rule1"
    http_listener_name         = ""
    backend_address_pool_name  = "bckname"
    backend_http_settings_name = "backendsettingsname"
    webappName                 = "samp-app-001"
    frontend_port              = "445"
    backend_port               = "446"
    frontendPort_name          = "FrontendportName"
    frontend_protocol          = "https"
    backend_protocol           = "Https"
  },


]



#Keyvault 
create_module                   = false
resource_group_name             = "demo"
location                        = "North Europe"
keyvault_name                   = ""
sku_name                        = "standard"
enabled_for_disk_encryption     = true
enabled_for_deployment          = true
enabled_for_template_deployment = true
enable_rbac_authorization       = false
purge_protection_enabled        = false
soft_delete_retention_days      = 7
create_resource_group           = true
object_id                       = ""
ip_rules                        = []
virtual_network_subnet_ids      = []
key_permissions                 = ["get", "list", "update", ]
secret_permissions              = ["get", "list", "delete", "recover", "backup", "restore", "set", ]
storage_permissions             = ["get", "list", "update", "delete", "recover", "backup", "restore", ]
create_keyvault_secret          = true
create_private_endpoint         = false
subnet_name                     = "keyvault"
virtual_network_name            = "sample-vnet"
vnet_resource_group_name        = "vnet-rg"
default_action                  = "Allow"
secret_list = ({
  "secret-for-certificate-name" = "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"
  "secret-for-certificate-pass" = "Apple@2066"
})
create_key_vault = true