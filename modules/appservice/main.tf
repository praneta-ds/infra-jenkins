resource "azurerm_service_plan" "asp" {
    name                = "${var.prefix}-asp"
    location            = var.location
    resource_group_name = var.resource_group_name
    sku_name            = var.sku_name
    os_type = var.ostype
}
resource "azurerm_windows_web_app" "app" {
    name                = "${var.prefix}-webapp"
    location            = var.location
    resource_group_name = var.resource_group_name
    service_plan_id = azurerm_service_plan.asp.id

    site_config {
        always_on = "false"
    }

    app_settings = {
        "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
}