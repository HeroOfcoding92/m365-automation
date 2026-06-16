<#
.SYNOPSIS
    Reports guest users with no sign-in activity in N days.

.DESCRIPTION
    Queries Entra ID for all external (B2B) guest accounts and
    filters those whose last sign-in exceeds the specified threshold.
    Output is exported to CSV for use in access reviews.

.PARAMETER DaysInactive
    Number of days without sign-in to flag a guest. Default: 90

.PARAMETER OutputPath
    Path for the CSV output. Default: .\stale-guests.csv

.EXAMPLE
    .\Get-StaleGuestReport.ps1 -DaysInactive 90 -OutputPath "C:\Reports\stale-guests.csv"

.NOTES
    Requires: User.Read.All, AuditLog.Read.All
    AuditLog.Read.All is needed to read signInActivity (Entra ID P1/P2).
#>

[CmdletBinding()]
param(
    [int]$DaysInactive = 90,
    [string]$OutputPath = ".\stale-guests.csv"
)

$context = Get-MgContext
if (-not $context) {
    Write-Warning "Not connected. Run: Connect-MgGraph -Scopes 'User.Read.All','AuditLog.Read.All'"
    exit 1
}

$cutoffDate = (Get-Date).AddDays(-$DaysInactive)
Write-Host "Fetching guest accounts (cutoff: $($cutoffDate.ToString('yyyy-MM-dd')))..." -ForegroundColor Yellow

$guests = Get-MgUser -All `
    -Filter "userType eq 'Guest'" `
    -Property Id, DisplayName, Mail, UserPrincipalName, CreatedDateTime, SignInActivity

$stale = $guests | Where-Object {
    $lastSignIn = $_.SignInActivity?.LastSignInDateTime
    (-not $lastSignIn) -or ($lastSignIn -lt $cutoffDate)
}

$report = $stale | Select-Object `
    @{N='DisplayName';   E={$_.DisplayName}},
    @{N='Email';         E={$_.Mail}},
    @{N='UPN';           E={$_.UserPrincipalName}},
    @{N='Created';       E={$_.CreatedDateTime}},
    @{N='LastSignIn';    E={$_.SignInActivity?.LastSignInDateTime ?? 'Never'}}

$report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "$($report.Count) stale guests (>$DaysInactive days) exported to: $OutputPath" -ForegroundColor Green
