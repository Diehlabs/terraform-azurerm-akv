provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}


data "azurerm_client_config" "current" {}

module "akv" {
  providers = {
    azurerm.axle = azurerm.axle
  }
  source                      = "../.."
  tags                        = local.tags
  tags_extra                  = var.tags_extra
  enabled_for_deployment      = false
  enabled_for_disk_encryption = false
  unique_id                   = var.unique_id
  subnet_id                   = data.azurerm_subnet.pe_subnet.id
  private_endpoint            = true
  environment                 = var.environment
  product                     = var.product
  resource_group_location     = module.resource_group.rg.location
  resource_group_name         = module.resource_group.rg.name
}

resource "azurerm_key_vault_access_policy" "akvowner" {
  key_vault_id = module.akv.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "Update", "Verify", "WrapKey", "UnwrapKey",
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set",
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update",
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update",
  ]
}
