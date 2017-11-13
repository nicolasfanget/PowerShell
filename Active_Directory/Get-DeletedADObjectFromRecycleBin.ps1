<#

Example: .\Get-DeletedADObjectFromRecycleBin.ps1 -Name DeletedObject -DomainController DC1

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Name,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$DomainController,
    [pscredential]$Credentials = (Get-Credential -Message "Enter AD Credentials")

)

Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*"' -Server $DomainController -IncludeDeletedObjects -Credential $Credentials | Where-Object {$_.Name -like "*$Name*"}