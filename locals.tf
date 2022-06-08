locals {
  all_tags = merge(
    var.tags_extra,
    var.tags
  )

  # -----------------------------------------------------------------------------
  # Generate the name for the key vault
  # Format: 3-24 char length, alpha-numeric and dashes, globally unique
  # -----------------------------------------------------------------------------
  # <company identifier>-<cloud region>-<environment>-<product>-<portfolio>-<initiative>-<team>-<application name>-<purpose>-kv
  # product_name_sanitized = lower(replace(replace(var.tags.product, " ", "-"), "_", "-"))
  # key_vault_base_name    = "${var.tags.environment}-${local.product_name_sanitized}"

  short_region_map = {
    westus    = "wus"
    eastus2   = "eus2"
    centralus = "cus"
    eastus    = "eus"
  }

  short_region = lookup(local.short_region_map, lower(var.resource_group_location))

  key_vault_base_name = "%s-%s-%s-kv"
  key_vault_name      = format(local.key_vault_base_name, local.short_region, var.environment, var.product)

  private_endpoint_name = "${local.key_vault_name}-pe"
}
