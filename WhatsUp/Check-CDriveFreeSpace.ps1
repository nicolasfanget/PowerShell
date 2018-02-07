# Define the hostname
$Hostname = $Context.GetProperty("Address")

# Define credentials used to connect (Make sure to specify windows credentials on the device)
$User =  $Context.GetProperty("CredWindows:DomainAndUserid")
$PWD = $Context.GetProperty("CredWindows:Password")
$SecurePWD = ConvertTo-SecureString -String "$PWD" -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $SecurePWD

# Define drive letter to check
$DriveLetter = "C:"

# Get WMI info from remote computer
$DriveInfo = Get-WmiObject -Class Win32_LogicalDisk -Namespace "root\cimv2" -ComputerName $Hostname -Credential $Credentials | Where-Object { $_.DeviceID -eq $DriveLetter }

# Get free space percentage
$FreeSpacePercentage = ($DriveInfo.FreeSpace / $DriveInfo.Size) * 100
$FreeSpacePercentage = ([math]::Round($FreeSpacePercentage))

# If free space percentage is greater than 20% report back we're good, other wise report back we have an issue
if ( $FreeSpacePercentage -gt 20 ) {

    $resultText = "$DriveLetter Free Space: $FreeSpacePercentage"
    $Context.SetResult(0, $resultText);

}

else {

    $resultText = "$DriveLetter Free Space: $FreeSpacePercentage"
    $Context.SetResult(1, $resultText);

}