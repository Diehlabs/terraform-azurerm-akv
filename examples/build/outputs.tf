# output "my_secret_value" {
#   value     = azurerm_key_vault_secret.example.value
#   sensitive = true
# }

# output "my_secret_name" {
#   value = azurerm_key_vault_secret.example.name
# }

output "key_vault_name" {
  value = module.akv.keyvault_name
}

output "key_vault_resource_group" {
  value = module.resource_group.rg.name
}
