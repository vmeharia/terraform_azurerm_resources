# Create a virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.virtual_machine_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_DS2_v2"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic.id]
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "79-gen2"
    version   = "7.9.2021051702"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  }

  tags       = local.common_tags
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_managed_disk" "data" {
  name                 = var.data_disk_name
  location             = azurerm_resource_group.rg.location
  create_option        = "Empty"
  disk_size_gb         = 128
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data-disk-attach" {
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  managed_disk_id    = azurerm_managed_disk.data.id
  lun                = 0
  caching            = "None"
}

resource "azurerm_virtual_machine_extension" "oms_ext" {
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId" : "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}


resource "azurerm_virtual_machine_extension" "da_ext" {
  name                       = "DependencyAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

}
