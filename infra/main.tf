resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

module "resource_group" {
  source = "./modules/resource_group"

  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

module "storage_account" {
  source = "./modules/storage_account"

  name                = local.names.storage_account
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  replication_type    = var.storage_replication_type
  tags                = local.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  log_analytics_name  = local.names.log_analytics
  app_insights_name   = local.names.app_insights
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = var.log_retention_in_days
  tags                = local.tags
}

module "service_plan" {
  source = "./modules/service_plan"

  name                = local.names.service_plan
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = var.service_plan_sku
  tags                = local.tags
}

module "function_app" {
  source = "./modules/function_app"

  name                = local.names.function_app
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  service_plan_id     = module.service_plan.id

  storage_account_name       = module.storage_account.name
  storage_account_access_key = module.storage_account.primary_access_key

  application_insights_connection_string = module.monitoring.app_insights_connection_string

  runtime_stack   = var.runtime_stack
  runtime_version = var.runtime_version
  always_on       = local.is_consumption ? false : var.always_on
  app_settings    = var.app_settings

  public_network_access_enabled = var.public_network_access_enabled

  tags = local.tags
}
