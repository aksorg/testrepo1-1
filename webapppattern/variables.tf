variable "application_name" {
  type        = string
  description = "Application name of project"
}

variable "environment_name" {
  type        = string
  description = "environment_name "
}

variable "webappName" {
  type        = string
  description = "Webapp Name"
  default = " "
}

variable "resource_group_name" {
  description = "Name of resource group"
  type        = string
   default = " "
}

variable "portfolio" {
  type        = string
  description = "portfolio name"
}

variable "location" {
  type        = string
  default     = "North Europe"
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "os_type" {
  default     = "Linux"
  type        = string
  description = "OS types (Linux/windows)"
}

variable "tags" {
  description = "The tags to associate with your app service plan"
  type        = map(string)
  default     = {}
}

variable "create_container" {
  description = "Create container or not"
  default     = false
}

variable "create_app_service_plan" {
  description = "Create container or not"
  default     = false
}


variable "app_service_plan_name" {
  description = "Create container or not"
  default     = ""
}

variable "container_sku" {
  description = "SKU in container"
  type        = string
  default     = "Premium"
}

variable "container_name" {
  description = "name for container"
  type        = string
   default = " "
}

variable "vnet_route_all_enabled" {
  description = "should all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied"
  default     = false
}