# m365-automation

PowerShell automation scripts for Microsoft 365 and Entra ID — focused on identity lifecycle, access reviews, and reporting.

## Contents

| Script | Purpose |
|---|---|
| `scripts/New-GuestUserBulk.ps1` | Bulk-invite external B2B guest users from CSV |
| `scripts/Get-StaleGuestReport.ps1` | Reports guest accounts with no sign-in in 90+ days |
| `scripts/Export-ConditionalAccessPolicies.ps1` | Exports all CA policies to JSON for documentation |

## Requirements

- PowerShell 7.x
- Microsoft.Graph PowerShell SDK
- Entra App Registration or interactive login with appropriate scopes

## Quick Start

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "User.ReadWrite.All", "Policy.Read.All", "AuditLog.Read.All"
```

## Script Highlights

### Guest User Bulk Invite

Reads a CSV (`Email, DisplayName, Department`) and sends B2B invitations:

```powershell
.\scripts\New-GuestUserBulk.ps1 -CsvPath ".\guests.csv" -RedirectUrl "https://myapps.microsoft.com"
```

### Stale Guest Report

Identifies guests who haven't signed in for 90 days — useful for access reviews:

```powershell
.\scripts\Get-StaleGuestReport.ps1 -DaysInactive 90 -OutputPath ".\stale-guests.csv"
```

### CA Policy Export

Snapshots all Conditional Access policies to JSON — handy before making changes:

```powershell
.\scripts\Export-ConditionalAccessPolicies.ps1 -OutputPath ".\ca-backup"
```

## Background

These scripts were developed as part of hands-on lab work for the SC-300 Microsoft Identity and Access Administrator certification. They target real-world tasks covered in the exam domains:

- Domain 1: Implement and manage user identities
- Domain 3: Implement access management for applications
- Domain 4: Plan and implement identity governance

## References

- [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/overview)
- [SC-300 Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/sc-300)
- [Entra ID B2B documentation](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)
