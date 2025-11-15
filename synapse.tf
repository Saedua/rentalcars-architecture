resource "azurerm_synapse_workspace" "synapse" {
    name = "synapse-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.data_lake_fs.id
    sql_administrator_login = "sqladminuser"
    sql_administrator_login_password = var.synapse_admin_password

    identity {
      type = "SystemAssigned"
    }

    tags = var.tags
}

# Firewall para servicios de Azure

resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
}

# Firewall para mi IP
resource "azurerm_synapse_firewall_rule" "allow_my_ip" {
  name = "AllowMyIP"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address = "181.115.60.60"
  end_ip_address = "181.115.60.60"
}

#Spark Pool
resource "azurerm_synapse_spark_pool" "spark_pool" {
  name = "sparkpool${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size_family = "MemoryOptimized"
  node_size = "Small"
  cache_size = 50

  auto_scale {
    max_node_count = 3
    min_node_count = 3
  }

  auto_pause {
    delay_in_minutes = 15
  }

  spark_version = "3.4"

  tags = var.tags
}

# Acceso del Synapse sobre eL DataLake

# Al SA del Data Lake
resource "azurerm_role_assignment" "synapse_to_datalake" {
  scope = azurerm_storage_account.data_lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

# Conexion Synapse con Data Lake

resource "azurerm_synapse_linked_service" "datalake_linked" {
  name = "AzureDataLakeStorage"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  type = "AzureBlobFS"
  type_properties_json = jsonencode({
    url = "https://${azurerm_storage_account.data_lake.name}.dfs.core.windows.net"
  })

  depends_on = [ azurerm_synapse_firewall_rule.allow_azure_services,
  azurerm_synapse_firewall_rule.allow_my_ip,
   azurerm_role_assignment.synapse_to_datalake ]
}
