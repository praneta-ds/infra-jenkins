output "service_name" {
  description = "The name of the App Service"
  value       = azurerm_windows_web_app.app.name
  
}
output "app_default_hostname" {
  value = azurerm_windows_web_app.app.default_hostname
}
output "azurerm_windows_web_app_plan_id" {
  value = azurerm_service_plan.asp.id
}