# Secretos del Key Vault

#Contrasenia SQL

resource "azurerm_key_vault_secret" "sql_password" {
  name = "sql-password"
  value = var.admin_sql_password

  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [ azurerm_key_vault.kv]
}

