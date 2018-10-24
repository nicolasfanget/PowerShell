<#

I wrote this script to get a list of AD Groups and their managedBy property.
This should come in handy when working on the IRM to FAU domain transition.

#>

# Get the group prefix and search base
$GRP_PREFIX = Read-Host "Enter Group Prefix"
$AD_SEARCHBASE = Read-Host "Enter AD SearchBase"

# Get the domain we are working on
$DOMAIN = Read-Host "Enter Domain we are working in"
$DOMAIN_CONTROLLER = Get-ADDomain -Identity $DOMAIN | Select-Object PDCEmulator

# Get the groups and store in DEPT_GROUPS variable
$DEPT_GRPS = Get-ADGroup -Filter "Name -like '*$GRP_PREFIX*'" -SearchBase $AD_SEARCHBASE -Properties Name, managedBy -Server $DOMAIN_CONTROLLER.PDCEmulator -Credential $AD_Creds

# Loop through the groups and print out the name and name of the manager
foreach ($GRP in $DEPT_GRPS) {

    try {

        # Try to get the group manager name
        $GRP_MGR = (Get-ADObject -Identity $GRP.managedBy -Server $DOMAIN_CONTROLLER.PDCEmulator | Select-Object Name).Name

    }
    # If we fail, assume no group manager
    catch { $GRP_MGR = "NO GROUP MANAGER" }

    Write-Host $GRP.Name : $GRP_MGR

}