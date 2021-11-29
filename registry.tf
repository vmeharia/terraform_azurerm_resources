# Create a Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = var.container_registry_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Premium"
  public_network_access_enabled = "false"
  tags                          = local.common_tags

  network_rule_set {
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.snet.0.id
    }
  }
}
