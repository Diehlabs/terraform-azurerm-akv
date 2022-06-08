data "azurerm_resource_group" "vnet_rg" {
  name = var.network_resource_group_name
}

data "azurerm_virtual_network" "pe_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "pe_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.pe_vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}
