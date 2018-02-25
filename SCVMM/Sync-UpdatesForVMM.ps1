<# 

This script syncs updates from WSUS to the VMM Library
Example: .\Sync-UpdatesForVMM.ps1 -VMMServer VMM1 -WsusServer WSUS1 -VMMBaseLine 'All Updates' -Products 'Windows Server 2016'

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$VMMServer,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$WsusServer,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$VMMBaseLine,
    [Parameter(Mandatory = $True, Position = 4)]
    [string]$Products

)

# Define date for output file formatting
$date = Get-Date -Format "MM-dd-yyyy"

# Verify logs folder exists, if not create it
if (!(Test-Path ".\logs")) {

    New-Item -ItemType Directory -Path ".\logs"

}

# Connect to our VMM server
Get-SCVMMServer -ComputerName $VMMServer | Out-Null

# Sync VMM's updates database with Wsus
Start-SCUpdateServerSynchronization -UpdateServer $WsusServer | Out-Null

# Get the baseline in the VMM library to add applicable updates to
$Baseline = Get-SCBaseline -Name $VMMBaseLine

# Get list of all updates that meet are criteria
$AllUpdates = Get-SCUpdate | Where-Object {($_.Products -like "*$Products*") -and ($_.IsExpired -eq $false) -and ($_.IsSuperseded -eq $false) -and ($_.Name -notlike "*Language Pack*")}

# Compare the baseline with all updates and add missing/new updates to the baseline
$UpdatesToAdd = Compare-Object -ReferenceObject $AllUpdates -Differenceobject $Baseline.Updates -PassThru | Where-Object {$_.SideIndicator -eq "<="}
$UpdatesToAdd | ForEach-Object {Set-SCUpdate $_ -AcceptLicenseAgreement}

# If there are updates to add to our baseline lets do that now
if ($UpdatesToAdd -ne $null) {

    Set-SCBaseline -Baseline $Baseline -Name $VMMBaseLine -RunAsynchronously -Description "All Updates" -AddUpdates $UpdatesToAdd | Out-File ".\logs\$date`_sync_vmm_updates_log.txt"

}