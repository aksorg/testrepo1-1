
variable "username" {
  type    = string
  default = "infobloxapi"
}

variable "password" {
  type    = string
  default = "Cloud@2019"
}

variable "host" {
  type    = string
  default = "10.126.241.36"
}
variable "environment_name" {
  type        = string
  default     = "Nonprod"
  description = "environment name"
}
variable "application_name" {
  type        = string
  description = "Application name of project"
}

# variable "webappName" {
#   type        = string
#   description = "Webapp Name"
# }

variable "resource_group_name" {
  description = "Name of resource group"
  type        = string
  default     = ""
} #need

variable "portfolio" {
  type        = string
  description = "portfolio name"
} #n

variable "location" {
  type        = string
  default     = "northeurope"
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
} #n

variable "plan" {
  type = object({
    name     = string
    sku_tier = string
    sku_size = string
  })
  default = {
    name     = ""
    sku_tier = "Standard"
    sku_size = "P1V2"
  }
  description = "A map of app service plan properties."
}

variable "app_service_plan_id" {
  description = "Existing App service plan resource ID. This is a required filed if create_app_service_plan variable is set to false"
  type        = string
  default     = ""
}

variable "create_app_service_plan" {
  default     = true
  description = "this is the case if it is to re-use an app service plan or create a new one"
}



variable "app_settings" {
  description = "Application settings for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#app_settings"
  type        = map(string)
  default     = {}
}

variable "secure_app_settings" {
  description = "map of secure environment variables that need to be set eg:  export TF_VAR_secure_app_settings='{\"Foo\":\"bar\",\"Fizz\":\"Buzz\", \"hello\":\"world\"}'"
  type        = map(string)
  default     = {}
}

variable "client_affinity_enabled" {
  description = "Client affinity activation for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#client_affinity_enabled"
  type        = bool
  default     = true
}

variable "https_only" {
  description = "HTTPS restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#https_only"
  type        = bool
  default     = true
}

variable "os_type" {
  default     = "Linux"
  type        = string
  description = "OS types (Linux/windows)"
} #n

variable "tags" {
  description = "The tags to associate with your app service plan"
  type        = map(string)
  default     = {}
}

variable "vnet_integration" {
  type    = bool
  default = true
}

variable "address_prefixes" {
  type    = list(string)
  default = []
}

variable "virtual_network_name" {
  type    = string
  default = ""
}

variable "app_service_plan_name" {
  description = "Existing App service plan resource name. This is a required filed if create_app_service_plan variable is set to false "
  default     = ""
}

variable "create_container" {
  type        = bool
  default     = true
  description = "whether to create a new acr"
}

variable "container_sku" {
  description = "SKU in container"
  type        = string
  default     = "Premium"
}

variable "container_name" {
  description = "name for existing container"
  type        = string
  default     = ""
}






# for Keyvault

variable "create_key_vault" {
  type        = bool
  default     = true
  description = "whether to create new keyvault"
}


variable "keyvault_sku_name" {
  type        = string
  default     = "standard"
  description = "Sku for keyvault"
}

variable "kv_enabled_for_disk_encryption" {
  type    = bool
  default = false
}

variable "kv_enabled_for_deployment" {
  type    = bool
  default = false
}

variable "kv_enabled_for_template_deployment" {
  type    = bool
  default = false
}

variable "kv_enable_rbac_authorization" {
  type    = bool
  default = false
}

variable "kv_purge_protection_enabled" {
  type    = bool
  default = false
}
variable "kv_soft_delete_retention_days" {
  type    = number
  default = 7
}


variable "kv_object_id" {
  type    = string
  default = ""
}

variable "kv_ip_rules" {
  type    = list(any)
  default = []
}

variable "kv_virtual_network_subnet_ids" {
  type    = list(any)
  default = []
}

variable "kv_key_permissions" {
  type    = list(string)
  default = ["get", ]
}

variable "kv_secret_permissions" {
  type    = list(string)
  default = ["get", "list", "set", "delete"]
}

variable "kv_storage_permissions" {
  type    = list(string)
  default = ["get", ]
}

variable "create_keyvault_secret" {
  type    = bool
  default = false
}

variable "kv_secret_list" {
  type = map(any)
  default = {
    "" = ""
  }
}


variable "kv_default_action" {
  type    = string
  default = "Deny"
}
