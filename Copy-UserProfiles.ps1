# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$RemoteComputer

)
$Directory = Get-ChildItem "C:\Users" | Where-Object { $_.Name -eq "fhudzinski" }

if (Test-Path "\\$RemoteComputer\c$\Users\$($Directory.Name)") {

    # /XJ switch is important as it stops AppData infinite loop
    # More info: https://answers.microsoft.com/en-us/windows/forum/windows_7-files/windows-7-infinite-loop-while-using-robocopy/20f32f0c-4cb9-4125-923d-6a57e4d27232?auth=1
    Robocopy.exe "C:\Users\$($Directory.Name)" "\\$RemoteComputer\c$\Users\$($Directory.Name)" /b /mir /mt /r:0 /w:0 /XJ /copyall

} else { Write-Host "Unable to access: \\$RemoteComputer\c$\Users\$($Directory.Name)" }