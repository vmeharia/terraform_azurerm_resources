# Create a AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.cluster_name
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  kubernetes_version      = "1.21.2"
  dns_prefix              = var.dns_prefix_name
  node_resource_group     = var.node_resource_group
  private_cluster_enabled = true
  sku_tier                = "Paid"

  role_based_access_control {
    enabled = true
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.identity.id
  }

  /*linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = file(var.ssh_key)
    }
  }*/

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    dns_service_ip     = var.service_ip
    docker_bridge_cidr = var.docker_cidr
    service_cidr       = var.service_cidr
  }

  default_node_pool {
    name           = "pool1"
    node_count     = var.agent_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.snet.0.id
  }

  addon_profile {

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    }
  }
  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {

  name                  = "pool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size
  node_count            = var.agent_count
  vnet_subnet_id        = azurerm_subnet.snet.0.id
}
