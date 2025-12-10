variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  
}
variable "location" {
  description = "The Azure location where resources will be created"
  type        = string   
}   
variable "app_service_plan_sku_name" {
  description = "The SKU name for the App Service Plan"
  type        = string  
}   
variable "ostype" {
  description = "The operating system type for the App Service Plan (e.g., 'Windows' or 'Linux')"
  type        = string
  
}