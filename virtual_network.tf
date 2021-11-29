# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_prefix]
  tags                = local.common_tags
}

# Create Three subnets
resource "azurerm_subnet" "snet" {
  name                                           = var.subnet_names[count.index]
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  resource_group_name                            = azurerm_resource_group.rg.name
  address_prefixes                               = [var.subnet_prefix[count.index]]
  service_endpoints                              = ["Microsoft.ContainerRegistry"]
  enforce_private_link_endpoint_network_policies = true
  count                                          = 4
}

# Create public IPs
/*resource "azurerm_public_ip" "pip"{
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}*/

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
  security_rule {
    name                       = "SSH"
    priority                   = 555
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = var.interface_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = azurerm_subnet.snet.1.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  network_interface_id      = azurerm_network_interface.nic.id
}
