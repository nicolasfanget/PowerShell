<#

I wrote this script to generate a permissions report for a file server that uses local groups for permissions on its shares
In the future I may add functionality to check on local or domain groups
Usage: .\Get-FileServerPermissionsByGroup.ps1 -$GroupFile .\Group_File.txt

#>
[CmdLetBinding()]
Param(

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupFile,
    [string]$FileServer = $env:computername

)

Get-Content $GroupFile | ForEach-Object {

    # Assign Group variable to GroupFile pipelined object
    $Group = $_
    
    # Formatting function
    Write-Output "-------------------------------------------------------------------------------"

    # Get members of the local group
    Write-Output "Members of $Group group"
    Get-LocalGroupMember $Group | Select-Object Name | Write-Output

    # I did this to create 2 new lines in the output since `n was not working
    Write-Output ""
    Write-Output ""

    # Get folders the group has access to
    Write-Output "Folders accessible to: $Group"
    $FileServerFolders = Get-ChildItem k:\transfer | Get-Acl | Select-Object Path -ExpandProperty Access | Where-Object { $_.IdentityReference -like "$FileServer\$Group" }
    # Need to format Path since it comes out of the box as PSPath
    $FileServerFolders | Select-Object Path, AccessControlType, FileSystemRights | Format-Table @{Label = "Path"; Expression = {Convert-Path $_.Path}}, AccessControlType, FileSystemRights | Write-Output

    # Formatting function
    Write-Output "-------------------------------------------------------------------------------"

} | Out-File "$GroupFile`_Permissions_Report.txt"