<#
  
  This script enables versioning on lists/libraries for site collections
  and all subsites. Credit goes to Arlena Wanat, I have only made minor modifications to her source code.
  https://gallery.technet.microsoft.com/office/Enable-versioning-for-all-ae5cfb5d

#>

function getall($urelek)
{
  $ctx=New-Object Microsoft.SharePoint.Client.ClientContext($urelek)
  $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password)
  $ctx.Load($ctx.Web.Lists)
  $ctx.Load($ctx.Web)
  $ctx.Load($ctx.Web.Webs)
  $ctx.ExecuteQuery()
  Write-Host 
  Write-Host $ctx.Url -BackgroundColor White -ForegroundColor DarkGreen
  foreach( $ll in $ctx.Web.Lists)
  {
    $ll.EnableVersioning = $versioning
    $ll.Update()
    $csvvalue= new-object PSObject
        $listurl=$null
        if($ctx.Url.EndsWith("/")) {$listurl= $ctx.Url+$ll.Title}
        else {$listurl=$ctx.Url+"/"+$ll.Title}
        $csvvalue | Add-Member -MemberType NoteProperty -Name "Url" -Value ($listurl)
        $csvvalue | Add-Member -MemberType NoteProperty -Name "Status" -Value "Failed"
        try
        {
        $ErrorActionPreference="Stop"
        $ctx.ExecuteQuery() 
        Write-Host $listurl -ForegroundColor DarkGreen
        $csvvalue.Status="Success"
        $Global:csv+= $csvvalue       
        }

        catch
        {
            $Global:csv+= $csvvalue
            Write-Host $listurl -ForegroundColor Red
        }
        finally
        {$ErrorActionPreference="Continue"}
        

  }

  if($ctx.Web.Webs.Count -gt 0)
  {
    for($i=0; $i -lt $ctx.Web.Webs.Count ; $i++)
    {
        getall($ctx.Web.Webs[$i].Url)
    }

  }
  
  

}

# Paths to SPO SDK. Please verify location on your computer if you have have any issues.
try {

    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

    # Versioning will be enabled
    $versioning = $true

    # Get site collection URL and username and password
    $siteUrl = Read-Host -Prompt "Enter site collection"

    $username = Read-Host -Prompt "Enter 365 Admin Username"
    $password = Read-Host -Prompt "Enter 365 Admin Password" -AsSecureString

    $credy = New-Object System.Management.Automation.PSCredential($username, $password) 

    Connect-SPOService -Credential $credy -Url "https://fau-admin.sharepoint.com/"

    $Global:csv = @()

    getall($siteUrl)

    # Specify the path where the log file will be published
    $Global:csv | Export-Csv -Path ".\Versioning_Results.csv"

    # Disconnect from SPO when our work is done
    Disconnect-SPOService

} catch { Write-Host "Unable to load SPO SDK's..." }