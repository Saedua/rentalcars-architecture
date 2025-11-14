data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name = "keyvault-rentalcars"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  sku_name = "standard"
}

# Politica de acceso del key vault al ADF para obtener permisos de leer

resource "azurerm_key_vault_access_policy" "adf_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_data_factory.adf.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

#Conexion ADF con Key Vault para obtener el secreto de la contrasenia de SQL

resource "azurerm_data_factory_linked_service_key_vault" "kv_linked" {
  name = "keyvault-linked-service"
  data_factory_id = azurerm_data_factory.adf.id
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update"
  ]
  
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
  
  certificate_permissions = [
    "Get", "List", "Create", "Delete"
  ]
}
