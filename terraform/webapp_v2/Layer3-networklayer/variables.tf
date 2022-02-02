
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
variable "portfolio" {
  description = "portfolio name"
  type        = string
} #n

variable "environment_name" {
  description = "environment name"
  type        = string
}

variable "application_name" {
  description = "application name"
  type        = string
} #n

variable "app_service_name" {
  description = "web app name"
  type        = string
  default     = ""
}
variable "appservice_rg" {
  description = "resource group name where web app is created"
  type        = string
  default     = ""
} #n
variable "acr_name" {
  description = "acr name for adding private endpoint"
  type        = string
  default     = ""
}
variable "keyvault_name" {
  description = "keyvault name for private endpoint"
  type        = string
  default     = ""
}

variable "vnet_rg" {
  description = "resource group name of vnet"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "virtual network name "
  type        = string
} #n
variable "vnet_integration_subnet" {
  description = "subnet for vnet integration with appservice"
  type        = string
} #n
variable "private_end_point_subnet" {
  description = "subnet for private endpoints"
  type        = string
} #n


variable "location" {
  description = "location of resource group"
  type        = string
  default     = "North europe"
} #n



