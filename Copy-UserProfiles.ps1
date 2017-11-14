<#

Make sure the account that runs this script has administrative priviledges on both computers
For the best results make sure the user is logged off the source computer
Usage: .\Copy-UserProfiles.ps1 -UserToCopy user1 -RemoteComputer remotepc1 -DomainController dc1

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$UserToCopy,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$RemoteComputer,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$DomainController

)

# We will need the user sid when it comes time to copy the profile
$UserSID = Get-ADUser -Server $DomainController -Identity $UserToCopy | Select-Object sid

# Copy the user profile from source machine to destination
if (Test-Path "\\$RemoteComputer\c$\Users\") {

    # /XJ switch is important as it stops AppData infinite loop
    # More info: https://answers.microsoft.com/en-us/windows/forum/windows_7-files/windows-7-infinite-loop-while-using-robocopy/20f32f0c-4cb9-4125-923d-6a57e4d27232?auth=1
    Robocopy.exe "C:\Users\$UserToCopy" "\\$RemoteComputer\c$\Users\$UserToCopy" /b /mir /mt /r:0 /w:0 /XJ /copyall

} else { Write-Host "Unable to access: \\$RemoteComputer\c$\Users\" }

# Export the registry entry from the src computer
reg.exe export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($UserSID.SID)" \\$RemoteComputer\c$\Users\TempUserProfile.reg
# Create the new registry profile on the remote computer
Invoke-Command $RemoteComputer { reg.exe import C:\Users\TempUserProfile.reg }
# Remove the temporary registry key file from dst computer
Invoke-Command $RemoteComputer { Remove-Item C:\Users\TempUserProfile.reg }