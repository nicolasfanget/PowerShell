<#

I wrote this script to set the group manager for a list of AD groups.
Note that this does not turn on the "manager can update membership list" option.
This should come in handy when working on the IRM to FAU domain transition.

#>

# Get the text file with group names
$AD_GRPS = Read-Host "Enter Path to Group Names Txt File"

# Get the domain we are working on
$DOMAIN = Read-Host "Enter Domain we are working in"
$DOMAIN_CONTROLLER = Get-ADDomain -Identity $DOMAIN | Select-Object PDCEmulator

# Get the group manager AD object
$GRP_MGR_NAME = Read-Host "Enter Name of Group to Become Manager"
$GRP_MGR = Get-ADGroup -Identity $GRP_MGR_NAME -Server $DOMAIN_CONTROLLER.PDCEmulator -Credential $AD_Creds

# Get the text file contents and loop through it
Get-Content $AD_GRPS | ForEach-Object {

    # Set the group manager
    Set-ADGroup -Identity $_ -ManagedBy $GRP_MGR -Server $DOMAIN_CONTROLLER.PDCEmulator -Credential $AD_Creds
}