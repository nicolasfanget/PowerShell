<#

Credit for this script goes to: https://gallery.technet.microsoft.com/office/Enable-versioning-for-all-83548eb6

#>

function Set-SPOListVersioning($EnableVersioning, $Urelek) {
  
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($urelek)
    $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username, $Adminpassword)
    $ctx.Load($ctx.Web.Lists)
    $ctx.Load($ctx.Web)
    $ctx.Load($ctx.Web.Webs)
    $ctx.ExecuteQuery()
    Write-Host 
    Write-Host $ctx.Url -BackgroundColor White -ForegroundColor DarkGreen

    foreach ( $ll in $ctx.Web.Lists) {
    
        $ll.EnableVersioning = $EnableVersioning
        $ll.Update()
        $csvvalue = new-object PSObject
        $listurl = $null
        if ($ctx.Url.EndsWith("/")) {$listurl = $ctx.Url + $ll.Title}
        else {$listurl = $ctx.Url + "/" + $ll.Title}
        $csvvalue | Add-Member -MemberType NoteProperty -Name "Url" -Value ($listurl)
        $csvvalue | Add-Member -MemberType NoteProperty -Name "Status" -Value "Failed"
        try {

            $ErrorActionPreference = "Stop"
            $ctx.ExecuteQuery() 
            Write-Host $listurl -ForegroundColor DarkGreen
            $csvvalue.Status = "Success"
            $Global:csv += $csvvalue       
        }

        catch {

            $Global:csv += $csvvalue
            Write-Host $listurl -ForegroundColor Red
            
        }
    
        finally {$ErrorActionPreference = "Continue"}
    
    }

    if ($ctx.Web.Webs.Count -gt 0) {

        for ($i = 0; $i -lt $ctx.Web.Webs.Count ; $i++) {

            Set-SPOListVersioning -EnableVersioning $EnableVersioning -Urelek ($ctx.Web.Webs[$i].Url)
        }

    }
}

$SPSDKLoaded = $false
# Load SharePoint Management SDK dll's
try {

    # Paths to SDK. Please verify location on your computer.
    Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
    Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    # Set $SPSDKLoaded so script moves to the next section
    $SPSDKLoaded = $true

} catch { Write-Host -ForegroundColor Red "Unable to load SPO SDK's..." }

if ($SPSDKLoaded -eq $true) {

    # Turn versioning on/off here
    $EnableVersioning = $true

    # Define credentials and name of OneDrive site
    $Username = Read-Host -Prompt "Enter 365 Admin Username"
    $AdminPassword = Read-Host -Prompt "Enter 365 Admin Password" -AsSecureString
    $credy = New-Object System.Management.Automation.PSCredential($Username, $AdminPassword)
    $myhost = "https://fau-my.sharepoint.com/personal/*"

    Connect-SPOService -Url "https://fau-admin.sharepoint.com/" -Credential $credy
    
    $Global:csv = @()

    # I had to change the logic for how it went through users, seemed to die when I feed it 60k users
    Get-SPOSite -IncludePersonalSite $true -Limit all | Where-Object { $_.Url -like $myhost } | ForEach-Object {

        # You must set yourself as a site collection admin for this script to work
        # Afterwards I remove the admin account from site admin
        Set-SPOUser -Site $_.Url -IsSiteCollectionAdmin $true -LoginName $Username
        
        Set-SPOListVersioning -EnableVersioning $EnableVersioning -Urelek $_.Url

        Set-SPOUser -Site $_.Url -IsSiteCollectionAdmin $false -LoginName $Username
  
    }

    # Specify the path where the log file will be published
    $Global:csv | Export-Csv -Path ".\OneDrive_Versioning.csv"

    # Disconnect from SPO
    Disconnect-SPOService

}