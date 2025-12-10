output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "app_service_name" {
  value = module.appservice.name
}   
output "app_service_default_site_hostname" {
  value = module.appservice.default_site_hostname
}
output "app_service_plan_id" {
  value = module.appservice.app_service_plan_id
}