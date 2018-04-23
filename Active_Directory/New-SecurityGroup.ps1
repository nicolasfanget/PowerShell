<#

I wrote this script to create mail enabled security groups to help clean-up our alias file
Usage example: .\New-SecurityGroup.ps1 -GroupName "Group1" -Users "user1","user2" 

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupName,
    [Parameter(Mandatory = $True, Position = 2)]
    [string[]]$Users

)

# Verify each user exists on Office 365, added try/catch block for non-existent users
foreach ($User in $Users) {

    try {

        $TargetAddress = (Get-ADUser -Identity $User -Server BOCDCFAU01 -Credential $AD_Creds -Properties TargetAddress).TargetAddress
        if ($TargetAddress -notlike "*@fau.mail.onmicrosoft.com") { Write-Host -ForegroundColor Yellow "$User is not on Office 365" }

    } catch { Write-Host -ForegroundColor Yellow "$User does not exist." }
    
}

# Create the group and add the users to it
New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupScope Universal -GroupCategory Security -Path "OU=DISTRIBUTION,OU=GROUPS,OU=SYSADMIN,DC=ad,DC=fau,DC=edu" -Server BOCDCFAU01 -Credential $AD_Creds
# I put this into a for loop so that non-existent users don't cause other members to not be added
foreach ($User in $Users) {
    
    Add-ADGroupMember -Identity $GroupName -Members $User -Server BOCDCFAU01 -Credential $AD_Creds

}