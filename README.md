# Azure Function App – Terraform

Modular Terraform for an Azure (Linux) Function App, deployed by an Azure DevOps YAML pipeline.

## Layout

```
infra/
├── main.tf / variables.tf / outputs.tf / locals.tf   # root module: wires modules together
├── versions.tf / providers.tf                        # provider pins + azurerm backend (partial)
├── .terraform.lock.hcl                               # provider checksums (linux + windows) - commit it
├── environments/
│   ├── dev/  { terraform.tfvars, backend.hcl }
│   └── prod/ { terraform.tfvars, backend.hcl }
└── modules/
    ├── resource_group/
    ├── storage_account/    # host storage for the function app
    ├── monitoring/         # Log Analytics + workspace-based App Insights
    ├── service_plan/       # Linux plan: Y1 / EP1-3 / dedicated
    └── function_app/       # azurerm_linux_function_app, system-assigned identity
pipelines/
├── azure-pipelines.yml                 # Validate -> Plan/Apply dev -> Plan/Apply prod
├── templates/terraform-environment.yml # Plan + Apply stages for one environment
├── templates/install-terraform.yml
└── scripts/terraform.ps1               # auth (OIDC or secret) + init + plan/apply (PowerShell 7)
```

## Prerequisites (one-time)

1. **State storage**: create a storage account + container for remote state. The names must match `infra/environments/*/backend.hcl`:
   ```powershell
   az group create -n rg-terraform-state -l eastus2
   az storage account create -n sttfstatefuncapp -g rg-terraform-state --sku Standard_LRS `
     --min-tls-version TLS1_2 --allow-blob-public-access false
   az storage container create -n tfstate --account-name sttfstatefuncapp --auth-mode login
   ```
2. **Service connections**: create Azure Resource Manager service connections named `sc-funcapp-dev` and `sc-funcapp-prod`. Workload identity federation is recommended. Each identity needs:
   - `Contributor` on the target subscription or resource group
   - `Storage Blob Data Contributor` on the state storage account (state uses Entra ID auth, not keys)
3. **Environments**: create Azure DevOps Environments `funcapp-dev` and `funcapp-prod`, and add approvals/checks (at least on prod).
4. **Pipeline**: create a pipeline from `pipelines/azure-pipelines.yml`.

## Pipeline behaviour

| Trigger          | Validate | Plan | Apply                                          |
|------------------|----------|------|------------------------------------------------|
| PR to `main`     | ✅       | ✅   | ❌                                             |
| Push to `main`   | ✅       | ✅   | ✅ only if the plan has changes, after env approvals |

The plan is saved as a pipeline artifact. Apply runs exactly that plan file. After apply, the step `tf` exposes `functionAppName` and `resourceGroupName` as output variables, so you can add a code-deployment stage (e.g. `AzureFunctionApp@2`). Terraform ignores `WEBSITE_RUN_FROM_PACKAGE`, so code deploys won't cause drift.

## Customising

- **Runtime**: `runtime_stack` (`dotnet-isolated`, `dotnet`, `node`, `python`, `java`, `powershell`) + `runtime_version`.
- **Hosting**: `service_plan_sku` – `Y1` (Consumption, dev default), `EP1` (Elastic Premium, prod default), or a dedicated SKU.
- **New environment**: copy `infra/environments/dev` and add another `terraform-environment.yml` template block to the pipeline.

## Running locally

```powershell
cd infra
az login
$env:ARM_SUBSCRIPTION_ID = az account show --query id -o tsv
terraform init -backend-config=environments/dev/backend.hcl
terraform plan -var-file=environments/dev/terraform.tfvars
```
