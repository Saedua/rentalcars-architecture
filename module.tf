output "app_insights_connection_string" {
    value = azurerm_application_insights.appinsights.connection_string
    sensitive = true
}

output "app_insights_app_id" {
  value = azurerm_application_insights.appinsights.app_id
}