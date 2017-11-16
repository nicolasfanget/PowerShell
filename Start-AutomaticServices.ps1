<#
This script looks for services that have a startup type of automatic that are not running and attempts to start them
#>
Get-CimInstance Win32_Service -Filter "startmode = 'auto' AND state != 'running'" | Select-Object Name, State | ForEach-Object {
    
    Start-Service $_.Name

}