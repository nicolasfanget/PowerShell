

function Send-TestEmail ($SmtpServer, $SmtpPort = "25", [switch]$UseTls, $From, $To) {

    # Setup the subject and body variables
    $Subject = "$SmtpServer test"
    $Body = "Test email from $SmtpServer using port $SmtpPort"

    # Send the email using SSL/TLS
    if ($UseTls) { Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -From $From -To $To -Subject $Subject -Body $Body }

    # Send the email without using SSL/TLS
    else { Send-MailMessage -SmtpServer $SmtpServer -Port $SmtpPort -From $From -To $To -Subject $Subject -Body $Body }

}

Export-ModuleMember -Function "Send-*"