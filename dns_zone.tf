# Create ALL DNS zones
resource "azurerm_private_dns_zone" "all-dns-zone" {
  name                = var.dns_names[count.index]
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
  count               = 6
}
resource "azurerm_private_dns_zone" "svc-local" {
  name                = "svc.local"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-vnet-link-svc" {
  name                  = var.dns_vnet_link_name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.svc-local.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
  tags                  = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-vnet-monitor" {
  name                  = "monitor-vnet-01"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = var.dns_names[count.index]
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.common_tags
  count                 = 6
}
