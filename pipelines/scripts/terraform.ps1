# Runs Terraform inside an AzureCLI@2 task (scriptType: pscore, addSpnToEnvironment: true).
#
# Usage: terraform.ps1 -Action <plan|apply> -Environment <env> [-PlanFile <path>]
#   plan  - writes <PlanFile> and sets output variable 'hasChanges'
#   apply - applies <PlanFile> and sets output variables from terraform outputs
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('plan', 'apply')]
    [string] $Action,

    [Parameter(Mandatory)]
    [string] $Environment,

    [string] $PlanFile = 'tfplan'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Runs a native command and throws if its exit code is not in $AllowedExitCodes.
function Invoke-Native {
    param(
        [Parameter(Mandatory)] [string] $FilePath,
        [string[]] $ArgumentList = @(),
        [int[]] $AllowedExitCodes = @(0)
    )
    # Stream output to the log; only the exit code goes down the pipeline.
    & $FilePath @ArgumentList | Out-Host
    if ($AllowedExitCodes -notcontains $LASTEXITCODE) {
        throw "$FilePath $($ArgumentList -join ' ') failed (exit $LASTEXITCODE)"
    }
    return $LASTEXITCODE
}

function Get-RequiredEnv([string] $Name, [string] $Hint) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrEmpty($value)) { throw "$Name not set$(if ($Hint) { " - $Hint" })" }
    return $value
}

# --- Authentication -------------------------------------------------------
# AzureCLI@2 exposes the service connection's identity as env variables.
# Workload identity federation (recommended) provides idToken; a secret-based
# service connection provides servicePrincipalKey instead.
$env:ARM_CLIENT_ID = Get-RequiredEnv 'servicePrincipalId' 'is addSpnToEnvironment enabled?'
$env:ARM_TENANT_ID = Get-RequiredEnv 'tenantId'
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
if ($LASTEXITCODE -ne 0 -or -not $env:ARM_SUBSCRIPTION_ID) { throw 'az account show failed' }

if ($env:idToken) {
    $env:ARM_USE_OIDC = 'true'
    $env:ARM_OIDC_TOKEN = $env:idToken
}
elseif ($env:servicePrincipalKey) {
    $env:ARM_CLIENT_SECRET = $env:servicePrincipalKey
}
else {
    throw 'no idToken or servicePrincipalKey available'
}

$env:TF_IN_AUTOMATION = 'true'
$env:TF_INPUT = 'false'

# --- Init -----------------------------------------------------------------
Invoke-Native terraform @('init', '-input=false', "-backend-config=environments/$Environment/backend.hcl") | Out-Null  # exit code only

switch ($Action) {
    'plan' {
        # 0 = no changes, 1 = error, 2 = changes present
        $rc = Invoke-Native terraform -AllowedExitCodes 0, 2 -ArgumentList @(
            'plan',
            '-input=false',
            '-lock-timeout=5m',
            "-var-file=environments/$Environment/terraform.tfvars",
            "-out=$PlanFile",
            '-detailed-exitcode'
        )

        $hasChanges = if ($rc -eq 2) { 'true' } else { 'false' }
        Write-Host "Plan has changes: $hasChanges"
        Write-Host "##vso[task.setvariable variable=hasChanges;isOutput=true]$hasChanges"
    }

    'apply' {
        Invoke-Native terraform @('apply', '-input=false', '-lock-timeout=5m', '-auto-approve', $PlanFile) | Out-Null  # exit code only

        # Surface non-sensitive outputs for later steps/stages (e.g. code deploy).
        $functionAppName = terraform output -raw function_app_name
        if ($LASTEXITCODE -ne 0) { throw 'terraform output function_app_name failed' }
        $resourceGroupName = terraform output -raw resource_group_name
        if ($LASTEXITCODE -ne 0) { throw 'terraform output resource_group_name failed' }

        Write-Host "##vso[task.setvariable variable=functionAppName;isOutput=true]$functionAppName"
        Write-Host "##vso[task.setvariable variable=resourceGroupName;isOutput=true]$resourceGroupName"
    }
}
