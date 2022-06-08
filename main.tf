data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "akv" {
  name                        = local.key_vault_name
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  enabled_for_deployment      = var.enabled_for_deployment
  purge_protection_enabled    = var.enable_purge_protection
  sku_name                    = "premium"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.all_tags

}

# -----------------------------------------------------------------------------
# Create a private endpoint for the key vault.
# Optional but default is to create the private EP.
# auto named by this module.
# -----------------------------------------------------------------------------

data "azurerm_private_dns_zone" "akv" {
  provider            = azurerm.axle
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "<pdns-rg-name>"
}
resource "azurerm_private_endpoint" "akv" {
  count               = var.private_endpoint ? 1 : 0
  name                = "${azurerm_key_vault.akv.name}-pe"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_dns_zone_group {
    name = "akv-zones"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.akv.id
    ]
  }
  private_service_connection {
    name                           = "${azurerm_key_vault.akv.name}-connection"
    private_connection_resource_id = azurerm_key_vault.akv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  tags = local.all_tags
}
