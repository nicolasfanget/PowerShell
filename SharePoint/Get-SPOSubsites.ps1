# Add the necessary runtime libraries
# If the script complains about these verify the paths
# Sometimes an update to the spo mgmt shell will change the path
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

# Get admin credentials
$365AdminUser = Read-Host -Prompt "Enter 365 Admin Username"
$AdminPassword = Read-Host -Prompt "Enter 365 Admin Password" -AsSecureString

# Get top level URL
$SiteCollectionUrl = Read-Host -Prompt "Enter 365 Site Collection URL"

function GetSPOWeb()
{
param (
		[Parameter(Mandatory=$true,Position=1)]
		[string]$Url,
        [Parameter(Mandatory=$false,Position=2)]
		[bool]$IncludeSubsites=$false
		)

    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($365AdminUser, $AdminPassword)
    $ctx.Load($ctx.Web)
    $ctx.Load($ctx.Web.Webs)
    $ctx.ExecuteQuery()

  for($i=0;$i -lt $ctx.Web.Webs.Count ;$i++)
     {
        $obj = new-Object PSOBject
        $obj | Add-Member NoteProperty AllowRSSFeeds($ctx.Web.Webs[$i].AllowRssFeeds)
        $obj | Add-Member NoteProperty Created($ctx.Web.Webs[$i].Created)
        $obj | Add-Member NoteProperty CustomMasterUrl($ctx.Web.Webs[$i].CustomMasterUrl)
        $obj | Add-Member NoteProperty Description($ctx.Web.Webs[$i].Description)
        $obj | Add-Member NoteProperty EnableMinimalDownload($ctx.Web.Webs[$i].EnableMinimalDownload)
        $obj | Add-Member NoteProperty ID($ctx.Web.Webs[$i].Id)
        $obj | Add-Member NoteProperty Language($ctx.Web.Webs[$i].Language)
        $obj | Add-Member NoteProperty LastItemModifiedDate($ctx.Web.Webs[$i].LastItemModifiedDate)
        $obj | Add-Member NoteProperty MasterUrl($ctx.Web.Webs[$i].MasterUrl)
        $obj | Add-Member NoteProperty QuickLaunchEnabled($ctx.Web.Webs[$i].QuickLaunchEnabled)
        $obj | Add-Member NoteProperty RecycleBinEnabled($ctx.Web.Webs[$i].RecycleBinEnabled)
        $obj | Add-Member NoteProperty ServerRelativeUrl($ctx.Web.Webs[$i].ServerRelativeUrl)
        $obj | Add-Member NoteProperty Title($ctx.Web.Webs[$i].Title)
        $obj | Add-Member NoteProperty TreeViewEnabled($ctx.Web.Webs[$i].TreeViewEnabled)
        $obj | Add-Member NoteProperty UIVersion($ctx.Web.Webs[$i].UIVersion)
        $obj | Add-Member NoteProperty UIVersionConfigurationEnabled($ctx.Web.Webs[$i].UIVersionConfigurationEnabled)
        $obj | Add-Member NoteProperty Url($ctx.Web.Webs[$i].Url)
        $obj | Add-Member NoteProperty WebTemplate($ctx.Web.Webs[$i].WebTemplate)

        Write-Output $obj
     }

    if($ctx.Web.Webs.Count -gt 0 -and $IncludeSubsites) {
     
        Write-Host "--"-ForegroundColor DarkGreen

        for($i=0;$i -lt $ctx.Web.Webs.Count ;$i++)
        {
            (GetSPOWeb $ctx.Web.Webs[$i].Url $IncludeSubsites)
        }
    }

}

# Run the function and output results to a txt file
GetSPOWeb -Url $SiteCollectionUrl -IncludeSubsites $true | Select-Object url | Format-Table -AutoSize | Out-File "SPO_Subsites.txt"