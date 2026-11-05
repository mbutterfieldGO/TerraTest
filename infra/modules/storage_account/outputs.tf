output "id" {
  description = "Storage account ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "Primary access key (consumed by the function app)."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}
