terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "41b20900-5acd-4553-902b-502c4c69e934"
}

resource "azurerm_resource_group" "rg" {
  name   = var.resource_group_name
  location = var.location
}
module "appservice" {
  source              = "../../modules/appservice"
  prefix =  var.prefix
  name             = "{var.prefix}-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.app_service_plan_sku_name
  ostype = var.ostype
 
}