<#

This script is designed to remove stale activesync devices
from an exchange environment. The goal would be to configure this script
in a way that lends itself to be ran as a scheduled task

Example using a group: .\Remove-StaleActiveSyncDevices.ps1 -DomainController DC1 -StaleAge 90 -Group "AD Group Name" 

Exmaple using a CSV: .\Remove-StaleActiveSyncDevices.ps1 -DomainController DC1 -StaleAge 90 -CsvPath "C:\test\StaleActiveSyncDevices.csv"

#>

# Define required variables of the script
[CmdletBinding()]
Param (
    
    # This will determine what DC to pull users from as well as the domain in multi-domain environments
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$DomainController,
    # Amount of time in days to consider an activesync device stale
    [Parameter(Mandatory = $True, Position = 2)]
    [int]$StaleAge,
    [string]$Group,
    [string]$CsvPath

)
# Setup stale age variable
$StaleAgeDays = (Get-Date).AddDays(-$StaleAge)
# Setup a date object for use in the script
$TodaysDate = Get-Date

# Logic for when a group is given as input
if ($Group -ne "") {

    # Get the email addresses of group members
    $GroupMembersEmailAddresses = Get-ADGroupMember -Server $DomainController -Identity $Group | Get-ADUser -Properties mail | Select-Object -Property mail
    
    # Loop through the group members email addresses to remove stale devices found
    $GroupMembersEmailAddresses | ForEach-Object {

        # Generate report of device(s) to be removed
        Write-Output "Stale devices removed for $($_.mail)"
        Get-MobileDeviceStatistics -Mailbox $_.mail | Where-Object { $_.LastSuccessSync -lt $StaleAgeDays } | `
            Select-Object -Property Guid, DeviceModel, LastSuccessSync | Format-Table -AutoSize | Write-Output
        Write-Output "`n`n"
        # Remove activesync device
        Get-MobileDeviceStatistics -Mailbox $_.mail | Where-Object { $_.LastSuccessSync -lt $StaleAgeDays } | Remove-MobileDevice -Confirm:$false

    } | Out-File ".\$($Group)_StaleDevices_Removal_Report_$($TodaysDate.Month)-$($TodaysDate.Day)-$($TodaysDate.Year).txt"
}

# Logic for when a CSV is given as input
if ($CsvPath -ne "") {

    # Logic for when the csv is accessible
    if (Test-Path $CsvPath) {

        # Setup an array to hold our email addresses
        $EmailAddresses = @()

        # Loop through the csv and add the email addresses to our array
        Import-Csv $CsvPath | ForEach-Object {

            $EmailAddresses += Get-ADUser -Server $DomainController $_.SamAccount -Properties mail | Select-Object -Property mail

        }

        # Loop through the array of email addresses to remove stale devices found
        # When we're confident in this code it will need to be changed to remove the devices
        $EmailAddresses | ForEach-Object {

            # Generate report of device(s) to be removed
            Write-Output "Stale devices removed for $($_.mail)"
            Get-MobileDeviceStatistics -Mailbox $_.mail | Where-Object { $_.LastSuccessSync -lt $StaleAgeDays } | `
                Select-Object -Property Guid, DeviceModel, LastSuccessSync | Format-Table -AutoSize | Write-Output
            Write-Output "`n`n"
            # Remove activesync device
            Get-MobileDeviceStatistics -Mailbox $_.mail | Where-Object { $_.LastSuccessSync -lt $StaleAgeDays } | Remove-MobileDevice -Confirm:$false

        } | Out-File ".\Csv_StaleDevices_Removal_Report_$($TodaysDate.Month)-$($TodaysDate.Day)-$($TodaysDate.Year).txt"

    } else { Write-Host "`nUnable to access: $CsvPath`n" -ForegroundColor "Red" }

}