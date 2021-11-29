# Assign network contributor to AKS identity
resource "azurerm_role_assignment" "role_network_contributor" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.snet.0.id
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

# Assign AcrPull role to AKS node pool identity
resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}
