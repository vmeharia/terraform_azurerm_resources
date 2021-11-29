resource "azurerm_lb" "lb" {
  name                = var.lb_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name = var.lb_frontend
    subnet_id = azurerm_subnet.snet.1.id
  }
  depends_on = [azurerm_virtual_machine_extension.oms_ext]

}

resource "azurerm_lb_backend_address_pool" "lb-bap" {
  name            = var.lb_bap
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-lb-bap" {
  ip_configuration_name   = "ipconfiguration1"
  network_interface_id    = azurerm_network_interface.nic.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bap.id
}

resource "azurerm_lb_nat_rule" "lb-nat-rule" {
  name                           = var.lb_nat_rule
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  protocol                       = "tcp"
  frontend_port                  = "22"
  backend_port                   = "22"
}

resource "azurerm_network_interface_nat_rule_association" "nic-nat" {
  network_interface_id  = azurerm_network_interface.nic.id
  ip_configuration_name = azurerm_network_interface.nic.ip_configuration[0].name
  nat_rule_id           = azurerm_lb_nat_rule.lb-nat-rule.id

}