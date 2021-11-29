# Create Private Endpoint for Acr
resource "azurerm_private_endpoint" "acr-pe" {
  name                = var.acr_pe_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet.0.id
  tags                = local.common_tags

  private_dns_zone_group {
    name                 = var.acr_dns_zone_name
    private_dns_zone_ids = [azurerm_private_dns_zone.all-dns-zone[0].id]
  }

  private_service_connection {
    name                           = var.acr_pe_connection_name
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

# Create Private Endpoint for AMPLS
resource "azurerm_private_endpoint" "ampls-pe" {
  name                = var.ampls_pe_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet.1.id
  tags                = local.common_tags

  private_dns_zone_group {
    name                 = var.ampls_dns_zone_name
    private_dns_zone_ids = [azurerm_private_dns_zone.all-dns-zone[1].id, azurerm_private_dns_zone.all-dns-zone[2].id, azurerm_private_dns_zone.all-dns-zone[3].id, azurerm_private_dns_zone.all-dns-zone[4].id, azurerm_private_dns_zone.all-dns-zone[5].id]
  }

  private_service_connection {
    name                           = var.ampls_pe_connection_name
    #private_connection_resource_id = lookup(azurerm_template_deployment.template.outputs, "ampls_id")
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }
}
