terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateproyecto"
    container_name       = "tfstate"
    key                  = "main.tfstate"
  }
}