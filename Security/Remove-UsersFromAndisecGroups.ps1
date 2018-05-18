<#

This script removes users from andisec groups for terminated FAU users
sent to us by OIT Security.

Usage: .\Remove-UsersFromAndisecGroups.ps1 -GroupName sftp* -InputDirectory \\fauandi1.fau.edu\systems\Terminations

#>

[CmdLetBinding()]
Param(

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupName,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$InputDirectory

)

# Get local groups to check
$LocalGroups = Get-LocalGroup | Where-Object { $_.Name -like $GroupName }

# Get all txt files in the input directory, load content into $Users variable
try {

    $Users = Get-ChildItem $InputDirectory | Where-Object { $_.Name -like "*.txt" } | Get-Content -ErrorAction Stop

} catch { exit }

# Check if output directory exists, if it doesn't make it or error out
if ((Test-Path "$InputDirectory\andisec_logs") -eq $false) {

    try {

        New-Item -Path "$InputDirectory\andisec_logs" -ItemType Directory -ErrorAction Stop | Out-Null
    } 
    catch {

        Write-Host "Fatal error creating output directory, exiting."
        exit
    }
}

# Loop through each user
foreach ($User in $Users) {

    # Loop through each group and remove the user
    $(foreach ($LocalGroup in $LocalGroups) {

        try {

            Remove-LocalGroupMember -Group $LocalGroup -Member $User -ErrorAction Stop
            Write-Output "Removed $User from $LocalGroup"

        }
        catch {}
    }) | Out-File "$InputDirectory\andisec_logs\$(Get-Date -Format yyyy-MM-dd)_$User.txt"
}