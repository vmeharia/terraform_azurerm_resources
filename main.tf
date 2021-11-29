# Configure the Microsoft Azure Provider
provider "azurerm" {

  features {}
}

locals {
  common_tags = {
    mots_id = "21053"
    app     = "test"
  }
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Create a user managed identity for AKS
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = var.identity_name
  tags                = local.common_tags
}
