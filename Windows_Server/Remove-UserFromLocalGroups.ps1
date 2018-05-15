<#

This script goes through group(s) and removes user(s) defined by a text file
Wildcards can be used for the GroupName paramater

Example: .\Remove-UserFromLocalGroups.ps1 -GroupName sftp* -UsersFile ".\Terminated_Users.txt"

#>


[CmdLetBinding()]
Param(

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupName,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$UsersFile

)

$LocalGroups = Get-LocalGroup | Where-Object { $_.Name -like $GroupName }
$Users = Get-Content $UsersFile

# Loop through each group and remove users from the UsersFile
foreach ($LocalGroup in $LocalGroups) {

    # If the script fails you can use the code below to find local groups with broken sids
    # This is a known issue with the Get-LocalGroupMember cmdlet, which may affect the Remove-LocalGroupMember cmdlet
    <#
    Write-Host "`n`n$LocalGroup Members:`n"
    $Users = Get-LocalGroupMember $LocalGroup -ErrorAction Stop | Select-Object Name
    Write-Host $Users.Name
    #>

    # Loop through each user and remove them from the current group
    foreach ($User in $Users) {

        try {

            Remove-LocalGroupMember -Group $LocalGroup -Member $User -ErrorAction Stop
            Write-Host "Removed $User from $LocalGroup"

        } catch {}
    }
}