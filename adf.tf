resource "azurerm_data_factory" "adf" {
  name = "rentalcars-data-factory"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  identity {
    type = "SystemAssigned"
  }
}

# Permisos del ADF sobre el Data Lake para que el ADF pueda escribir en el Data Lake

resource "azurerm_role_assignment" "adf_to_datalake" {
  scope = azurerm_storage_account.data_lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_data_factory.adf.identity[0].principal_id
}

# Conexion del ADF al SQL Databse

resource "azurerm_data_factory_linked_service_sql_server" "sql_linked" {
  name = "sql-linked-service"
  data_factory_id = azurerm_data_factory.adf.id
  connection_string = "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${azurerm_mssql_server.sqlserver.fully_qualified_domain_name};Initial Catalog=${azurerm_mssql_database.sqldb.name};User ID=sqladmin"

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.kv_linked.name
    secret_name = "sql-password"
  }
}

# Conexion del ADF al Data Lake

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "datalake_linked" {
  name = "datalake_linked_service"
  data_factory_id = azurerm_data_factory.adf.id
  url = "https://${azurerm_storage_account.data_lake.name}.dfs.core.windows.net"
  use_managed_identity = true
}