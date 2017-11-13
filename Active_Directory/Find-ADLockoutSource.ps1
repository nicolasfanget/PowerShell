<#

Example: .\Find-ADLockoutSource.ps1 -User LockedUser -DomainName contoso.com

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$User,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$DomainName,
    [pscredential]$Credentials = (Get-Credential -Message "Enter AD Credentials")

)

# Obtain PDC Emulator of the domain
$PDC = Get-ADDomainController -DomainName $DomainName -Discover -Service PrimaryDC

#Collect lockout events for user from last hour
Get-WinEvent -ComputerName $PDC.Name -Credential $Credentials -Logname Security `
-FilterXPath “*[System[EventID=4740 and TimeCreated[timediff(@SystemTime) <= 3600000]] and EventData[Data[@Name='TargetUserName']='$User']]” | `
Select-Object TimeCreated,@{Name=‘User Name’;Expression={$_.Properties[0].Value}},@{Name=‘Source Host’;Expression={$_.Properties[1].Value}}