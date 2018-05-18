<#

This script removes non-standard groups from terminated FAU users
sent to us by OIT Security.

Usage: .\Remove-NonStandardFAUGroups.ps1 -InputDirectory \\fauandi1.fau.edu\systems\Terminations

#>

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$InputDirectory

)

# Get all txt files in the input directory, load content into $Users variable
try {

    $Users = Get-ChildItem $InputDirectory | Where-Object { $_.Name -like "*.txt" } | Get-Content -ErrorAction Stop

} catch { exit }

# Check if output directory exists, if it doesn't make it or error out
if ((Test-Path "$InputDirectory\logs") -eq $false) {

    try {

        New-Item -Path "$InputDirectory\logs" -ItemType Directory -ErrorAction Stop | Out-Null
    } 
    catch { exit }
}

# Iterate through each user and remove groups
foreach ($User in $Users) {

    # Define Standard FAU groups that should not be removed from a user's account
    $StandardFAUGroups = @("FAU-GRP-STUDENT", "FAU-GRP-STAFF", "FAU-GRP-FACULTY", "FAU-GRP-EMPLOYEE", "Domain Users")

    # Remove all leading and trailing white space (input sanitation)
    $User = $User.trim()

    # Get principal group membership excluding standard FAU groups
    $ADGroups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object { $_.Name -notin $StandardFAUGroups } | Select-Object Name, distinguishedName

    # Iterate through each group and remove the user's membership
    $(foreach ($ADGroup in $ADGroups) {

        # Logic for removing IRM domain groups
        if ($ADGroup.distinguishedName -like "*DC=irm,DC=ad,DC=fau,DC=edu") {

            Set-ADObject -Identity $ADGroup.distinguishedName -Remove @{member = "$((Get-ADUser -Identity $User).distinguishedName)"} -Server BOCDCIRM01
            Write-Output $ADGroup.Name

        }
        # Logic for removing FAU domain groups
        else {
    
            Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADGroup.Name -Confirm:$false
            Write-Output $ADGroup.Name

        }
    }) | Out-File "$InputDirectory\logs\$(Get-Date -Format yyyy-MM-dd)_$User.txt"
} 

# Verify processed directory exists, if it doesn't then create it
if ((Test-Path "$InputDirectory\processed") -eq $false) {

    try {

        New-Item -Path "$InputDirectory\processed" -ItemType Directory -ErrorAction Stop | Out-Null
    } 
    catch { exit }
}
# Rename the processed txt files
Get-ChildItem $InputDirectory | Where-Object { $_.Name -like "*.txt" } | ForEach-Object {

    Rename-Item -Path "$InputDirectory\$_" -NewName "$(Get-Date -Format yyyy-MM-dd)_$_"

} 
# Move the processed txt files to the processed directory
Get-ChildItem $InputDirectory | Where-Object { $_.Name -like "*.txt" } | ForEach-Object {

    Move-Item -Path "$InputDirectory\$_" -Destination "$InputDirectory\processed"

} 