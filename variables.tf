variable "tags" {
  description = "Tag information to be assigned to resources created."
  type = object({
    cost_center       = string
    environment       = string
    owner             = string
    technical_contact = string
  })
}

variable "tags_extra" {
  description = "Optional extra tag information to be assigned to resources created."
  type        = map(any)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group that the Azure Key Vault will be created in. If this is set to null, a resource group name will be automatically generated."
  type        = string
  default     = null
}

variable "resource_group_location" {
  description = "The location of the resource group that the Azure Key Vault will be created in"
  type        = string
}

variable "unique_id" {
  description = "A unique identifier for use in resource names."
  type        = string
  default     = null
}

variable "environment" {
  description = "Name of the environment(prod,dev etc)"
  type        = string
}

variable "product" {
  description = "Name of product associated with resource"
  type        = string
}


variable "enabled_for_deployment" {
  description = "Enable Key Vault for Deployment"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = false
}

variable "private_endpoint" {
  type        = bool
  default     = true
  description = <<EOD
Create private endpoint for the Key Vault.
Defaults to true, setting false requires security exception.
EOD
}

variable "subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = null
}

variable "enable_purge_protection" {
  description = "Determine if purge protection is enabled"
  type        = bool
  default     = true
}
