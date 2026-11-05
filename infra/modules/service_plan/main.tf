resource "azurerm_service_plan" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  # Only Elastic Premium plans support burst scaling settings.
  maximum_elastic_worker_count = startswith(var.sku_name, "EP") ? var.maximum_elastic_worker_count : null

  tags = var.tags
}
