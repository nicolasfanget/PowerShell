# Script for sending email

# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$SmtpServer,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$From,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$To,
    [string]$SmtpPort = "25",
    [bool]$UseSSL = $false

)
# Setup the subject and body variables
$Subject = "$SmtpServer test"
$Body = "Test email from $SmtpServer using port $SmtpPort"
# Sends an email without using SSL
if ($UseSSL -eq $false) {

    Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -To $To -From $From -Subject $Subject -Body $Body

}
# Sends an email using SSL
elseif ($UseSSL -eq $True) {

    Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -To $To -From $From -Subject $Subject -Body $Body -UseSsl

}