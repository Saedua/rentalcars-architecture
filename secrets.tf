# Secretos del Key Vault

#Contrasenia SQL

resource "azurerm_key_vault_secret" "sql_password" {
  name = "sql-password"
  value = var.admin_sql_password

  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [ azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "synapse_password" {
  name = "synapse-password"
  value = var.synapse_admin_password
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [ azurerm_key_vault_access_policy.terraform_user ]
}