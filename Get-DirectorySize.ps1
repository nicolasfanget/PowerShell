<#

This script lists size information for a given directory


#>

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Directory

)

function Get-FolderSize([string] $InputDirectory) {

    # Calculate folder size
    $Folder = Get-ChildItem -Path $InputDirectory -Force -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "C:\Users\All Users" } | `
    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue

    # Convert to MB
    $FolderSize = [math]::Round(($Folder.Sum / 1MB), 2)

    # Logic for when size is 0
    if ($FolderSize -eq 0) {

        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "Directory"
        $Row."Name" = $InputDirectory
        $Row."Size" = "0 KB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is less than a MB
    elseif ($FolderSize -lt 1) {

        $FolderSize = [math]::Round(($Folder.Sum / 1KB), 2)
        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "Directory"
        $Row."Name" = $InputDirectory
        $Row."Size" = "$FolderSize KB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is a GB or more
    elseif ($FolderSize -gt 1000) {

        $FolderSize = [math]::Round(($Folder.Sum / 1GB), 2)
        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "Directory"
        $Row."Name" = $InputDirectory
        $Row."Size" = "$FolderSize GB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is between a MB and GB
    else {

        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "Directory"
        $Row."Name" = $InputDirectory
        $Row."Size" = "$FolderSize MB"
        $ItemsArray.Rows.Add($Row)

    }
}

function Get-ItemSize([string] $InputFile) {

    # Calculate folder size
    $Folder = Get-Item -Path $InputFile -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue

    # Convert to MB
    $ItemSize = [math]::Round(($Folder.Sum / 1MB), 2)

    # Logic for when size is 0
    if ($ItemSize -eq 0) {

        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "File"
        $Row."Name" = $InputFile
        $Row."Size" = "0 KB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is less than a MB
    elseif ($ItemSize -lt 1) {

        $ItemSize = [math]::Round(($Folder.Sum / 1KB), 2)
        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "File"
        $Row."Name" = $InputFile
        $Row."Size" = "$ItemSize KB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is a GB or more
    elseif ($ItemSize -gt 1000) {

        $ItemSize = [math]::Round(($Folder.Sum / 1GB), 2)
        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "File"
        $Row."Name" = $InputFile
        $Row."Size" = "$ItemSize GB"
        $ItemsArray.Rows.Add($Row)

    }
    # Logic for when size is between a MB and GB
    else {

        # Create a new entry in the table
        $Row = $ItemsArray.NewRow()
        $Row."Type" = "File"
        $Row."Name" = $InputFile
        $Row."Size" = "$ItemSize MB"
        $ItemsArray.Rows.Add($Row)

    }
}

# Create a table to hold the folder and files information
$ItemsArray = New-Object System.Data.DataTable "Files and Folders"
$Column1 = New-Object System.Data.DataColumn "Type", ([string])
$Column2 = New-Object System.Data.DataColumn "Name", ([string])
$Column3 = New-Object System.Data.DataColumn "Size", ([string])
$ItemsArray.Columns.Add($Column1)
$ItemsArray.Columns.Add($Column2)
$ItemsArray.Columns.Add($Column3)

# Get directory sizes, exclude files and reparse points (symbolic links)
Get-ChildItem -Path $Directory -Force -Attributes Directory+!ReparsePoint | ForEach-Object {

    Get-FolderSize($_.FullName)

}

# Get file sizes
Get-ChildItem -Path $Directory -Force -Attributes !Directory+!System | ForEach-Object {

    Get-ItemSize($_.FullName)

}

Write-Output $ItemsArray | Format-Table -AutoSize