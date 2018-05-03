<#

This script searches for accounts on an exchange online tenant that do not have auditing turned on
and enables auditing. Note the password file must be an encrypted string.

Example: .\Enable-ExchangeOnlineAuditing -365Username admin@tenant.onmicrosoft.com -365PwdFile c:\scripts\365password.txt

#>

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$365Username,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$365PwdFile

)

# Setup date/time variable
$Date = "{0:yyyy_MM_dd}" -f (Get-Date)

# Create credentials to connect to exchange online
$365Password = Get-Content $365PwdFile | ConvertTo-SecureString
$365Cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $365Username, $365Password

# Connect to Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $365Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Get mailboxes that do not have auditing enabled and turn it on, log the email addresses of who got turned on
Get-Mailbox -ResultSize Unlimited | Where-Object { $_.AuditEnabled -eq $false } | ForEach-Object {

    Set-Mailbox -Identity $_.PrimarySmtpAddress -AuditEnabled $true -AuditOwner @{Add = "Create", "SoftDelete", "HardDelete", "Update", "Move", "MoveToDeletedItems", "MailboxLogin", "UpdateFolderPermissions"}
    Write-Output "Enabled mailbox auditing for: $($_.PrimarySmtpAddress)"

} | Out-File ".\logs\Enable-ExchangeOnlineAuditing_Log_$Date.log"

# Disconnect from Exchange Online
Remove-PSSession $Session