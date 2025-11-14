resource "azurerm_iothub" "iot_hub" {
  name                = "iothub-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    name     = "S1"
    capacity = 1
  }

  tags = var.tags
}


/*
MENSAJERIA Y ENVIO DE LOGS AL DATA LAKE
*/
resource "azurerm_storage_container" "iot_logs" {
  name                  = "iot-logs"
  storage_account_id    = azurerm_storage_account.data_lake.id
  container_access_type = "private"
}


resource "azurerm_iothub_endpoint_storage_container" "datalake_endpoint" {
  name                = "datalake-endpoint"
  iothub_id           = azurerm_iothub.iot_hub.id

  resource_group_name = azurerm_resource_group.rg.name

  container_name    = azurerm_storage_container.iot_logs.name
  connection_string = azurerm_storage_account.data_lake.primary_connection_string

  # Frecuencia de escritura (batch)
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
    batch_frequency_in_seconds = 60
    encoding                   = "JSON"
}


resource "azurerm_iothub_route" "iothub_to_datalake" {
  name                = "route-to-datalake"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iot_hub.name

  source         = "DeviceMessages"
  enabled        = true
  condition      = "true"
  endpoint_names = [
    azurerm_iothub_endpoint_storage_container.datalake_endpoint.name
  ]
}
