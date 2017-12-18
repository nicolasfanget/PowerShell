# Prompt for tenant admin URL
$TenantAdminURL = Read-Host -Prompt "Enter tenant admin url"

# Prompt for 365 Credentials
$SPO_Credentials = Get-Credential -Message "Enter Office 365 Credentials"

Connect-SPOService -Url $TenantAdminURL -Credential $SPO_Credentials

# Make sure to disconnect session when done
# Disconnect-SPOService