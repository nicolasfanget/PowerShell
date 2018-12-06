<#

I wrote this script to backup my dad's surface to a usb flash drive
Utilizes robocopy for transferring files

#>

# Get drive letter of USB drive
$UsbDriveLetter = Read-Host -Prompt "Enter usb drive letter"
$UsbDriveLetter = $UsbDriveLetter.ToUpper()

# Create a folder on the usb drive with today's date to store the backup
$Date = (Get-Date -Format yyyyMMdd).ToString()
$BackupDirectory = "$UsbDriveLetter`:\backup_$Date"
New-Item -ItemType Directory -Path $BackupDirectory -ErrorAction SilentlyContinue -ErrorVariable FileError | Out-Null

if ($FileError) {

    Write-Host -ForegroundColor "Red" "Unable to create directory: $BackupDirectory"
    break

}

# Get location of user profile
$UserProfile = Read-Host -Prompt "Enter path of user profile"

# Backup the desktop directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Desktop" "$BackupDirectory\Desktop"

# Backup the documents directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Documents" "$BackupDirectory\Documents"

# Backup the downloads directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Downloads" "$BackupDirectory\Downloads"

# Backup the music directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Music" "$BackupDirectory\Music"

# Backup the pictures directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Pictures" "$BackupDirectory\Pictures"

# Backup the videos directory
Robocopy.exe /copyall /b /r:3 /w:0 /MT /E /XJ /NP /NFL "$UserProfile\Videos" "$BackupDirectory\Videos"