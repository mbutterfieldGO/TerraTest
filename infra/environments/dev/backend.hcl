# Remote state for the dev environment.
# The storage account/container must exist before the first pipeline run
# (see README.md -> "Prerequisites").
resource_group_name  = "rg-terraform-state"
storage_account_name = "sttfstatefuncapp"
container_name       = "tfstate"
key                  = "funcapp/dev.tfstate"
use_azuread_auth     = true
