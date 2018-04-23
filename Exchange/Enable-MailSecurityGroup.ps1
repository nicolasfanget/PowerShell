<#

I wrote this script to create mail enabled security groups to help clean-up our alias file
This is part 2 of the script to be ran on the exchange server
Usage example: .\Enable-MailSecurityGroup.ps1 -GroupName "Group1" 

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupName

)

# Create the distribution group
Enable-DistributionGroup -Identity $GroupName -Alias $GroupName
Set-DistributionGroup -BypassSecurityGroupManagerCheck -RequireSenderAuthenticationEnabled $false -Identity $GroupName