variable "tags_extra" {
  description = "Tags to assign to Terratest resources."
  type        = map(string)
  default     = {}
}
variable "unique_id" {
  description = "A unique identifier for use in resource names."
  type        = string
}

variable "network_resource_group_name" {
  type        = string
  description = "The name of the vnet"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet"
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet"
}

variable "environment" {
  description = "Name of the environment(prod, dev and so on)"
  type        = string
}

variable "product" {
  description = "Name of product associated with resource"
  type        = string
}


variable "resource_group_location" {
  description = "The location of the resource group that the Azure Key Vault will be created in"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group that the Azure Key Vault will be created in. If this is set to null, a resource group name will be automatically generated."
  type        = string
}
