<#

Usage example: .\Remove-Files.ps1 -Directory C:\directory -StaleAge 30

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Directory,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$StaleAge

)

# Get the files older than $StaleAge days and delete them permanently
Get-ChildItem $Directory | Where-Object { $_.LastWriteTime -lt ((Get-Date).AddDays( - $StaleAge)) } | Remove-Item