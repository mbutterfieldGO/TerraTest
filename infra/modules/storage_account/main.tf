resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  # Required: the Functions host uses key-based access for AzureWebJobsStorage
  # and for the content file share on Consumption / Elastic Premium plans.
  shared_access_key_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}
