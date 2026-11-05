locals {
  # Short, unique suffix for globally-unique names (storage, function app).
  suffix = random_string.suffix.result

  base_name = "${var.project}-${var.environment}"

  names = {
    resource_group  = "rg-${local.base_name}-${var.location_short}"
    storage_account = substr("st${var.project}${var.environment}${local.suffix}", 0, 24)
    log_analytics   = "log-${local.base_name}-${var.location_short}"
    app_insights    = "appi-${local.base_name}-${var.location_short}"
    service_plan    = "asp-${local.base_name}-${var.location_short}"
    function_app    = "func-${local.base_name}-${local.suffix}"
  }

  # Consumption (Y1) plans do not support Always On.
  is_consumption = var.service_plan_sku == "Y1"

  tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}
