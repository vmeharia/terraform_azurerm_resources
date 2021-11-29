resource "azurerm_log_analytics_workspace" "law" {
  name = "test-law"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = "test-ampls"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_private_link_scoped_service" "scoped" {
  name                = "test-amplsservice"
  resource_group_name = azurerm_resource_group.rg.name
  scope_name          = azurerm_monitor_private_link_scope.ampls.name
  linked_resource_id  = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_log_analytics_solution" "aks-sol" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_name        = azurerm_log_analytics_workspace.law.name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  tags                  = local.common_tags
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_log_analytics_solution" "vm-sol" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name
  tags                  = local.common_tags
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
}