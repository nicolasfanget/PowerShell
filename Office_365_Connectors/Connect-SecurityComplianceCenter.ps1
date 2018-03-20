<#

This script creates a remote powershell connection to Office 365 Security & Compliance center
It uses an encrypted text file with the admin password

Example: .\Connect-SecurityComplianceCenter.ps1

#>

# Create credential object
$365Username = "it-fhudzinski@fau.onmicrosoft.com"
$365Password = Get-Content ".\Office_365_Connectors\365_it-fhudzinski.txt" | ConvertTo-SecureString
$365Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $365Username, $365Password

# Create and import the remote powershell session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $365Credentials -Authentication Basic -AllowRedirection 
Import-PSSession $Session -AllowClobber -DisableNameChecking 

# Remind user to disconnect their session
Write-Host -ForegroundColor Yellow "`n`nRemember to disconnect your remote session using: Remove-PSSession `$Session"