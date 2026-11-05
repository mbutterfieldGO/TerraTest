locals {
  is_dotnet = contains(["dotnet", "dotnet-isolated"], var.runtime_stack)
}

resource "azurerm_linux_function_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  functions_extension_version   = "~4"
  https_only                    = true
  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = var.always_on
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true

    application_insights_connection_string = var.application_insights_connection_string

    application_stack {
      dotnet_version              = local.is_dotnet ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime_stack == "dotnet-isolated" ? true : null
      node_version                = var.runtime_stack == "node" ? var.runtime_version : null
      python_version              = var.runtime_stack == "python" ? var.runtime_version : null
      java_version                = var.runtime_stack == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime_stack == "powershell" ? var.runtime_version : null
    }
  }

  app_settings = var.app_settings

  tags = var.tags

  lifecycle {
    # Code deployment (zip deploy / run-from-package) and the portal manage these.
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}
