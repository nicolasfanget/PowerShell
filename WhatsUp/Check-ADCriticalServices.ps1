# Define credentials used to connect (Make sure to specify windows credentials on the device)
$User = $Context.GetProperty("CredWindows:DomainAndUserid")
$Password = $Context.GetProperty("CredWindows:Password")
$SecurePassword = ConvertTo-SecureString -String "$Password" -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword

# Define the host to connect to
$Hostname = $Context.GetProperty("Address")

# Define error message to use
$ErrorMsg = "The following service(s) are not running: "

# Define variable used to determine if all services are running
$ServicesNotRunning = 0

# Define the critical services
$CriticalServices = @("ADWS", "NetLogon", "NTDS", "KDC", "IsmServ", "W32time", "DFSR")

# Check each service
foreach ($Service in $CriticalServices) {

    $ServiceStatus = Get-WmiObject win32_service -ComputerName $Hostname -Credential $Credentials | Where-Object { $_.Name -eq $Service }

    if ( $ServiceStatus.State -ne "Running" -or $ServiceStatus.Status -ne "OK" ) {

        # Append our error msg and increment services not running variable
        $ErrorMsg = $ErrorMsg + "$Service "
        $ServicesNotRunning++

    }
}

# Report back all services running
if ( $ServicesNotRunning -eq 0 ) {

    $resultText = "All Services are running."
    $Context.SetResult(0, $resultText);

}
# Else report the issues we found
else {

    $resultText = $ErrorMsg 
    $Context.SetResult(1, $resultText);

}