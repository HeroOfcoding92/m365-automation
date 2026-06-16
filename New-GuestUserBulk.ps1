<#
.SYNOPSIS
    Bulk-invites B2B guest users from a CSV file.

.DESCRIPTION
    Reads a CSV with columns Email, DisplayName (and optionally Department)
    and sends Entra ID B2B invitations to each address.

.PARAMETER CsvPath
    Path to the input CSV file. Required columns: Email, DisplayName

.PARAMETER RedirectUrl
    URL guests are redirected to after accepting the invitation.
    Default: https://myapps.microsoft.com

.EXAMPLE
    .\New-GuestUserBulk.ps1 -CsvPath ".\guests.csv"

.NOTES
    Requires: User.Invite.All
    CSV format: Email,DisplayName,Department
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [string]$RedirectUrl = "https://myapps.microsoft.com"
)

$context = Get-MgContext
if (-not $context) {
    Write-Warning "Not connected. Run: Connect-MgGraph -Scopes 'User.Invite.All'"
    exit 1
}

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV not found: $CsvPath"
    exit 1
}

$guests = Import-Csv -Path $CsvPath
Write-Host "Loaded $($guests.Count) entries from CSV." -ForegroundColor Cyan

$results = @()

foreach ($guest in $guests) {
    if (-not $guest.Email -or -not $guest.DisplayName) {
        Write-Warning "Skipping row — missing Email or DisplayName: $($guest | ConvertTo-Json -Compress)"
        continue
    }

    try {
        if ($PSCmdlet.ShouldProcess($guest.Email, "Send B2B Invitation")) {
            $invitation = New-MgInvitation -InvitedUserEmailAddress $guest.Email `
                -InvitedUserDisplayName $guest.DisplayName `
                -InviteRedirectUrl $RedirectUrl `
                -SendInvitationMessage:$true

            $results += [PSCustomObject]@{
                Email       = $guest.Email
                DisplayName = $guest.DisplayName
                Status      = $invitation.Status
                InviteId    = $invitation.Id
            }
            Write-Host "  Invited: $($guest.DisplayName) <$($guest.Email)> — $($invitation.Status)" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "  Failed: $($guest.Email) — $($_.Exception.Message)"
        $results += [PSCustomObject]@{
            Email       = $guest.Email
            DisplayName = $guest.DisplayName
            Status      = "Error: $($_.Exception.Message)"
            InviteId    = $null
        }
    }
}

$results | Format-Table -AutoSize
Write-Host "`nDone. $($results.Count) invitations processed." -ForegroundColor Cyan
