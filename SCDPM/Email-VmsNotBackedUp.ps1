<#

This script compares the virtual machines on a cluster with those being backed up by DPM.
It will email a list of computers that are not being backed up.
Make sure to run this on the DPM server and that the DPM server has the FCM PowerShell module installed.

Usage: .\Email-VmsNotBackedUp.ps1 -Cluster HVCLUST01 -SmtpServer smtp.contoso.com

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Cluster,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$SmtpServer,
    [string]$DPMServer = $env:computername

)
# Create an empty array to store DPM Protected resources
$BackedUpVMs = @()

# Get protected Hyper-V VM's
$ProtectionGroup = Get-DPMProtectionGroup -DPMServerName $DPMServer | Where-Object { $_.Name -like "*Hyper*" }
$BackedUpVMsTemp = Get-DPMDatasource -ProtectionGroup $ProtectionGroup | Where-Object { $_.ObjectType -eq "Microsoft Hyper-V" -and $_.Computer -like "SCVMM*" } | Select-Object Computer

# Loop through and remove " Resources" from the string
foreach ($VMResource in $BackedUpVMsTemp) {

    $TruncatedVMResource = $VMResource.Computer
    $TruncatedVMResource = $TruncatedVMResource.Replace(" Resources", "")
    # Add the sanitized input to the final list
    $BackedUpVMs += $TruncatedVMResource

}

# Get Hyper-V VM's in specified cluster
$ClusteredVMs = Get-ClusterResource -Cluster $Cluster | Where-Object { $_.ResourceType -eq "Virtual Machine" } | Select-Object -ExpandProperty Name

# Compare the 2 lists and store only items that are in the ReferenceObject
$VMsNotBackedUp = Compare-Object -ReferenceObject $ClusteredVMs -DifferenceObject $BackedUpVMs | Where-Object { $_.SideIndicator -eq "<=" } | Select-Object InputObject | Sort-Object InputObject

# Create the plain text email body
foreach ($VM in $VMsNotBackedUp) {

    $EmailBody += Write-Output "$($VM.InputObject)`n"

}

# Send an email to the backup admins
$ToAddr = @("fhudzinski@fau.edu")
Send-MailMessage -SmtpServer $SmtpServer -From "$DPMServer@fau.edu" -To $ToAddr -Subject "Hyper-V Virtual Machines on Cluster $Cluster Not Backed Up By $DPMServer" -Body $EmailBody