resource "azurerm_storage_account" "storage" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = local.common_tags

}

data "azurerm_storage_account_sas" "storage-sas" {
  connection_string = azurerm_storage_account.storage.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2021-08-24T00:00:00Z"
  expiry = "2021-08-25T05:00:00Z"

  permissions {
    read  = true
    write = true


    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
}

/*output "sas_url_query_string" {
  value = data.azurerm_storage_account_sas.storage-sas.sas
}*/

data "template_file" "test" {
  template = file("diagsettings.tpl")
  vars = {
    storage_name = azurerm_storage_account.storage.name
    vm_id        = azurerm_linux_virtual_machine.vm.id
  }
}
resource "azurerm_virtual_machine_extension" "vm_linux_diagnostics" {
  count                      = "1"
  name                       = "storage-diagnostics"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = "true"

  settings = data.template_file.test.rendered

  protected_settings = <<PROTECTED_SETTINGS
    {
        "storageAccountName": "${(azurerm_storage_account.storage.name)}",
        "storageAccountSasToken": "${(data.azurerm_storage_account_sas.storage-sas.sas)}"
    }
    PROTECTED_SETTINGS
}
