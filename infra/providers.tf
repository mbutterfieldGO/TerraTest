# Authentication is taken from ARM_* environment variables set by the pipeline
# (ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_USE_OIDC / ARM_OIDC_TOKEN).
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  # Use Entra ID auth instead of shared keys for data-plane storage calls.
  storage_use_azuread = true
}
