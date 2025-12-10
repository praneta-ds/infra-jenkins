terraform {
  backend "azurerm" {
    resource_group_name = "rg-tfstate"
    storage_account_name = "terraformtfstate05"
    container_name = "tfstate"
    key = "envs/prod.terrafrom.tfstate"
  }
}