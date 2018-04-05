<#

This script disables a compromised account and sends an email
to the appropriate parties.

#>

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Identity,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$Reason,
    [string]$SmtpServer = "smtp.fau.edu",
    [string]$FromAddress = "fhudzinski@fau.edu",
    [string]$ToAddress = "myfauacct@fau.edu",
    [string[]]$CcAddress = @("systems@fau.edu", "security@fau.edu")

)

# Disable the account
Set-ADUser -Identity $Identity -Enabled $false -Server BOCDCFAU01 -Credential $AD_Creds

# Send mail to myfauacct, security and systems
Send-MailMessage -SmtpServer $SmtpServer -From $FromAddress -To $ToAddress -Cc $CcAddress `
    -Subject "Compromised Account Disabled: $Reason" `
    -Body "The following account has been compromised and has been disabled in AD:`n`n$Identity`n`nReason: $Reason"