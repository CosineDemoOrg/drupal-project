resource "azurerm_virtual_network" "vnet" {
  name                = "${local.base_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "web" {
  name                 = "${local.base_name}-web-sn"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.web_subnet_cidr]
}

# Optional subnet for Azure Bastion (required if create_bastion = true)
resource "azurerm_subnet" "bastion" {
  count                = var.create_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}