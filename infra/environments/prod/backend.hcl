# Remote state for the prod environment.
resource_group_name  = "rg-terraform-state"
storage_account_name = "sttfstatefuncapp"
container_name       = "tfstate"
key                  = "funcapp/prod.tfstate"
use_azuread_auth     = true
