<#
.SYNOPSIS
    Exports all Conditional Access policies to JSON files.

.DESCRIPTION
    Reads all CA policies from Entra ID and saves each as a
    named JSON file — useful for version control and pre-change snapshots.

.PARAMETER OutputPath
    Directory for JSON output. Created if it doesn't exist. Default: .\ca-backup

.EXAMPLE
    .\Export-ConditionalAccessPolicies.ps1 -OutputPath "C:\CA-Backup\2024-06"

.NOTES
    Requires: Policy.Read.All
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\ca-backup"
)

$context = Get-MgContext
if (-not $context) {
    Write-Warning "Not connected. Run: Connect-MgGraph -Scopes 'Policy.Read.All'"
    exit 1
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

Write-Host "Fetching Conditional Access policies..." -ForegroundColor Yellow

$policies = Get-MgIdentityConditionalAccessPolicy -All

foreach ($policy in $policies) {
    $safeName = $policy.DisplayName -replace '[^\w\-]', '_'
    $filePath  = Join-Path $OutputPath "$safeName.json"
    $policy | ConvertTo-Json -Depth 10 | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "  Saved: $($policy.DisplayName) → $filePath" -ForegroundColor Gray
}

Write-Host "`nDone. $($policies.Count) policies exported to: $OutputPath" -ForegroundColor Green
