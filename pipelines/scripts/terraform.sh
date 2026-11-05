#!/usr/bin/env bash
# Runs Terraform inside an AzureCLI@2 task (addSpnToEnvironment: true).
#
# Usage: terraform.sh <plan|apply> <environment> [plan-file]
#   plan  - writes <plan-file> and sets output variable 'hasChanges'
#   apply - applies <plan-file> and sets output variables from terraform outputs
set -euo pipefail

ACTION="${1:?action (plan|apply) required}"
ENVIRONMENT="${2:?environment required}"
PLAN_FILE="${3:-tfplan}"

# --- Authentication -------------------------------------------------------
# AzureCLI@2 exposes the service connection's identity as env variables.
# Workload identity federation (recommended) provides idToken; a secret-based
# service connection provides servicePrincipalKey instead.
export ARM_CLIENT_ID="${servicePrincipalId:?servicePrincipalId not set - is addSpnToEnvironment enabled?}"
export ARM_TENANT_ID="${tenantId:?tenantId not set}"
ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
export ARM_SUBSCRIPTION_ID

if [[ -n "${idToken:-}" ]]; then
  export ARM_USE_OIDC=true
  export ARM_OIDC_TOKEN="$idToken"
else
  export ARM_CLIENT_SECRET="${servicePrincipalKey:?no idToken or servicePrincipalKey available}"
fi

export TF_IN_AUTOMATION=true
export TF_INPUT=false

# --- Init -----------------------------------------------------------------
terraform init -input=false -backend-config="environments/${ENVIRONMENT}/backend.hcl"

case "$ACTION" in
  plan)
    set +e
    terraform plan \
      -input=false \
      -lock-timeout=5m \
      -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
      -out="$PLAN_FILE" \
      -detailed-exitcode
    rc=$?
    set -e

    # 0 = no changes, 1 = error, 2 = changes present
    case $rc in
      0) has_changes=false ;;
      2) has_changes=true ;;
      *) echo "##vso[task.logissue type=error]terraform plan failed (exit $rc)"; exit "$rc" ;;
    esac

    echo "Plan has changes: $has_changes"
    echo "##vso[task.setvariable variable=hasChanges;isOutput=true]$has_changes"
    ;;

  apply)
    terraform apply -input=false -lock-timeout=5m -auto-approve "$PLAN_FILE"

    # Surface non-sensitive outputs for later steps/stages (e.g. code deploy).
    function_app_name="$(terraform output -raw function_app_name)"
    resource_group_name="$(terraform output -raw resource_group_name)"
    echo "##vso[task.setvariable variable=functionAppName;isOutput=true]$function_app_name"
    echo "##vso[task.setvariable variable=resourceGroupName;isOutput=true]$resource_group_name"
    ;;

  *)
    echo "Unknown action '$ACTION' (expected plan or apply)" >&2
    exit 1
    ;;
esac
