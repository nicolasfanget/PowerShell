# Script creates a new send connector to 365

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Name,    
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$FQDN,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$SmartHosts

)

# Create the new send connector
New-SendConnector -Name $Name -AddressSpaces * -Fqdn $FQDN -RequireTLS $true -DNSRoutingEnabled $false `
-SmartHosts $SmartHosts -TlsAuthLevel CertificateValidation -MaxMessageSize 30MB

# Disable the old send connector
Set-SendConnector -Identity "All" -Enabled $false

# Restart transport service so our changes take effect
Restart-Service MSExchangeTransport