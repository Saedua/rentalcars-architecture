output "app_insights_connection_string" {
    value = azurerm_application_insights.appinsights.connection_string
    sensitive = true
}

output "app_insights_app_id" {
  value = azurerm_application_insights.appinsights.app_id
}

output "synapse_workspace_name" {
  value = azurerm_synapse_workspace.synapse.name
}

output "synapse_workspace_url" {
  value = "https://${azurerm_synapse_workspace.synapse.name}.dev.azuresynapse.net"
}

