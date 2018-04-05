<# 

This script adds the registry entry to add "run as other user" in windows 10 start menu
It then reboots the computer
Make sure to run as an admin

#>

# this function is used to pause the reboot from the script
# all it does is take user input from read host and pipes it to out null
function PauseReboot() {

    Write-Host "Press any key to continue..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}

# set registry variables
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
$DWORDKey = "ShowRunasDifferentuserinStart"

# warn user of impending reboot
Write-Host "`n`n`Warning! Successful execution of this script will result in system reboot!`nYou have been warned!"
PauseReboot

# test for the existence of the registy path
$RegPathExists = Test-Path $RegistryPath

# logic for what to do when the registry path doesnt exist
if ( $RegPathExists -eq $false ) {

    # if the registry folder does not exist lets create it
    Write-Host "Registry path does not exist. Creating $RegistryPath"
    New-Item -Path $RegistryPath -Force | Out-Null

    # test now to see that registry folder is created
    $RegPathExists = Test-Path $RegistryPath

    # logic for what to do when registry path is created
    if ( $RegPathExists -eq $true ) {

        # now that we have registry folder, lets create the dword key-value pair
        Write-Host "Registry path exists! Creating necessary DWORD key-value."
        New-ItemProperty -Path $RegistryPath -Name $DWORDKey -Value 1 -PropertyType DWORD | Out-Null

        # pause the script, as soon as user hits a key we will reboot
        Write-Host "A reboot is required for changes to take effect."
        PauseReboot
        Restart-Computer
    }
}