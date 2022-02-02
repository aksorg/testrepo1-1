
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
variable "clientid" {
  type    = string
  default = ""
}

variable "clientpass" {
  type    = string
  default = ""
}

variable "tenant" {
  type    = string
  default = ""
}
variable "subscription" {
  type    = string
  default = ""
}
variable "portfolio" {
  description = "portfolio name"
  type        = string
}

variable "environment_name" {
  description = "environment name "
  type        = string
  default     = "dev"
}

variable "application_name" {
  description = "application name"
  type        = string
}

variable "gateway_tier_name" {
  description = "The Name of the SKU to use for this Application"
  default     = "Standard_Medium"
  type        = string
  validation {
    condition = anytrue([
      var.gateway_tier_name == "Standard_Small",
      var.gateway_tier_name == "Standard_Medium",
      var.gateway_tier_name == "Standard_Large",
      var.gateway_tier_name == "WAF_Medium",
      var.gateway_tier_name == "WAF_Large"
    ])
    error_message = "Tier name must be Standard_Small, Standard_medium, Standard_Large, WAF_Medium , WAF_Large."
  }
}



variable "gateway_tier" {
  description = "The Tier of the SKU to use for this Application Gateway"
  default     = "Standard"
  type        = string
  validation {
    condition = anytrue([
      var.gateway_tier == "Standard",
      var.gateway_tier == "WAF"
    ])
    error_message = "Tier must be Standard or WAF."
  }


}

variable "private_ip_address_allocation" {
  type        = string
  default     = "Dynamic"
  description = "The Allocation Method for the Private IP Address. Possible values are Dynamic and Static"

}

variable "static_private_ip" {
  type        = string
  description = "IP address for Static Private IP"
  default     = ""
}


variable "capacity" {
  description = "The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32"
  type        = number
  default     = 2
}


variable "appgw_vnet_resource_group_name" {
  description = "Resource group for the Vnet to used with App gateway"
  type        = string
  default     = ""

}


variable "appgw_virtual_network_name" {
  description = "Name of the virtual network to used with App gateway"
  type        = string

} #n


variable "backend_ip_address" {
  description = "IP address for backend pool"
  type        = list(string)
  default     = []
}


variable "gateway_subnet_name" {
  description = "Name of the gateway subnet to be provided for App gateway"
  type        = string
  default     = ""


} #n

variable "address_prefixes" {
  type    = list(string)
  default = []
}

variable "create_subnet" {
  type    = bool
  default = true
}

variable "keyvault_name" {
  description = "The Vault Name for the secret to be used in App gateway.(if keyvault secret already exist)"
  type        = string
  default     = ""
}



variable "keyvault_rg" {
  description = "The Vault Resource group.(if keyvault secret already exist)"
  type        = string
  default     = ""
}




variable "kv_secret_certificate_data_name" {

  description = "The Secret of the associated SSL Certificate which should be used for the HTTP Listener(if keyvault secret already exist)"
  default     = ""
  type        = string
  sensitive   = true
} #senstve



variable "kv_secret_certificate_pass_name" {

  description = "The Secret of the associated SSL Certificate password which should be used for the HTTP Listener(if keyvault secret already exist)"
  default     = ""
  type        = string
  sensitive   = true
} #senstve



variable "backend_address_pool_list" {
  description = "backend address pool list of application gateway"
  type = list(object({

    name       = string
    fqdns      = list(string)
    ip_address = list(string) #make as optional

  }))

  default = []

}

variable "frontend_port_list" {
  description = "frontend port list of application gateway"
  type = list(object({

    name = string
    port = number


  }))

  default = []

}




variable "backend_http_settings_list" {
  description = "backend http settings list for application gateway"
  type = list(object({

    name            = string
    port            = number
    protocol        = string
    request_timeout = number
    probe_name      = string
  }))

  default = []

}


variable "request_routing_rule_list" {
  description = "request routing list for application gateway"
  type = list(object({

    name                       = string
    backend_http_settings_name = string
    backend_address_pool_name  = string
    http_listener_name         = string
  }))

  default = []

}


variable "http_listener_list" {
  description = "http listerner list for application gateway"
  type = list(object({

    name               = string
    frontend_port_name = string
    protocol           = string
  }))

  default = []

}
variable "health_probe_list" {
  description = "health probe list for application gateway "
  type = list(object({
    pick_host_name_from_backend_http_settings = string
    name                                      = string
    protocol                                  = string
    path                                      = string
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number

  }))

  default = []
}

variable "app_service_name" {
  description = "web application name"
  type        = string
  default     = ""
}

variable "fqdn" {
  type    = string
  default = ""
}
#Keyvault



variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
  default     = ""
} #n

variable "location" {
  type        = string
  description = "RG location in Azure"
  default     = "North europe"
} #n


variable "kv_sku_name" {
  description = "sku size for keyvault"
  type        = string
  default     = "standard"
}

variable "kv_object_id" {
  description = "object id for keyvault"
  type        = string
  default     = ""
}

variable "kv_ip_rules" {
  description = "list of ip for keyvault"
  type        = list(any)
  default     = []
}


variable "kv_secret_permissions" {
  description = "secret permissions for keyvault"
  type        = list(string)
  default     = ["get", "list", "set", "delete"]
}



variable "kv_secret_certificate_data" {

  description = "The Secret of the associated SSL Certificate which should be used for the HTTP Listener"
  default     = ""
  type        = string
  sensitive   = true
} #senstve



variable "kv_secret_certificate_pass" {

  description = "The Secret of the associated SSL Certificate password which should be used for the HTTP Listener"
  default     = ""
  type        = string
  sensitive   = true
} #senstve
