<#

This script creates a remote powershell connection to Office 365 SharePoint Online
It uses an encrypted text file with the admin password

Example: .\Connect-SharePointOnline.ps1

#>

$TenantAdminURL = "https://fau-admin.sharepoint.com/"

# Create credential object
$365Username = "it-fhudzinski@fau.onmicrosoft.com"
$365Password = Get-Content ".\Office_365_Connectors\365_it-fhudzinski.txt" | ConvertTo-SecureString
$365Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $365Username, $365Password

Connect-SPOService -Url $TenantAdminURL -Credential $365Credentials

# Remind user to disconnect their session
Write-Host -ForegroundColor Yellow "`n`nRemember to disconnect your remote session using: Disconnect-SPOService"