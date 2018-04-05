<#

This script disables the following client and server ssl/tls suites: SSL 3.0, TLS 1.0, TLS 1.1
Becareful when running on older operating systems such as Server 2008 R2, make sure RDP can use TLS 1.2
You can also edit the $Protocols string array to disable the desired encryption suites

#>

function DisableSuite ([string] $Protocol) {
    
    $SChannelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\"
    # Check is $Protocol Reg Key Exists
    if (Test-Path "$SChannelPath$Protocol") {
    
        # Check if Client Key Exists
        if (Test-Path "$SChannelPath$Protocol\Client") {

            if ((Get-ItemProperty -Path "$SChannelPath$Protocol\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue).DisabledByDefault -ne 1) {

                Write-Host "Configuring $Protocol Client Registry Key"
                Set-ItemProperty -Path "$SChannelPath$Protocol\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
                Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

            }
            # Else create the dword
            elseif ((Test-Path "$SChannelPath$Protocol\Client\DisabledByDefault") -eq "False") {

                Write-Host "Configuring $Protocol Client Registry Key"
                New-ItemProperty -Path "$SChannelPath$Protocol\Client" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null
                Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

            }
        }
        # Else create the client key and all subkeys
        else {

            Write-Host "Creating $Protocol Client Registry Key"
            New-Item -Path "$SChannelPath$Protocol\Client" -Force | Out-Null

            Write-Host "Configuring $Protocol Client Registry Key"
            New-ItemProperty -Path "$SChannelPath$Protocol\Client" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null
            Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow
        }

        # Check if Server Key Exists
        if (Test-Path "$SChannelPath$Protocol\Server") {

            if ((Get-ItemProperty -Path "$SChannelPath$Protocol\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue).DisabledByDefault -ne 1) {

                Write-Host "Configuring $Protocol Server Registry Key"
                Set-ItemProperty -Path "$SChannelPath$Protocol\Server" -Name "DisabledByDefault" -Value 1 | Out-Null
                Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

            }
            # Else create the dword
            elseif ((Test-Path "$SChannelPath$Protocol\Server\DisabledByDefault") -eq "False") {

                Write-Host "Configuring $Protocol Server Registry Key"
                New-ItemProperty -Path "$SChannelPath$Protocol\Server" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null
                Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

            }
        }
        # Else create the Server key and all subkeys
        else {

            Write-Host "Creating $Protocol Server Registry Key"
            New-Item -Path "$SChannelPath$Protocol\Server" -Force | Out-Null

            Write-Host "Configuring $Protocol Server Registry Key"
            New-ItemProperty -Path "$SChannelPath$Protocol\Server" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null
            Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

        }
    }
    # Else create the $Protocol key and all subkeys
    else {

        Write-Host "Creating $Protocol Registry Key"
        New-Item -Path "$SChannelPath$Protocol" -Force | Out-Null

        Write-Host "Creating $Protocol Client Registry Key"
        New-Item -Path "$SChannelPath$Protocol\Client" -Force | Out-Null

        Write-Host "Configuring $Protocol Client Registry Key"
        New-ItemProperty -Path "$SChannelPath$Protocol\Client" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null

        Write-Host "Creating $Protocol Server Registry Key"
        New-Item -Path "$SChannelPath$Protocol\Server" -Force | Out-Null

        Write-Host "Configuring $Protocol Server Registry Key"
        New-ItemProperty -Path "$SChannelPath$Protocol\Server" -Name "DisabledByDefault" -Value 1 -PropertyType DWORD | Out-Null

        Write-Host "Warning: Reboot required for changes to take effect!" -ForegroundColor Yellow

    }
}

# Define the protocols we want to disable
$Protocols = @("SSL 3.0", "TLS 1.0", "TLS 1.1")

# Loop through each and disable them
foreach ($Protocol in $Protocols) { DisableSuite($Protocol) }