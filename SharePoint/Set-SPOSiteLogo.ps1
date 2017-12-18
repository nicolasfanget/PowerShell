# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$UrlToUpdate,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$LogoUrl = (Read-Host -Prompt "Enter the Logo Url to use"),
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$365AdminUser = (Read-Host -Prompt "Enter 365 Admin Username"),
    [Parameter(Mandatory = $True, Position = 4)]
    [securestring]$SecurePassword = (Read-Host -Prompt "Enter 365 Admin Password" -AsSecureString)

)

# Load cmdlets for SPO functions
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")


Function Set-WebLogo([Microsoft.SharePoint.Client.ClientContext]$Content,[string]$SiteLogoUrl)
{
    $Context.Web.SiteLogoUrl = $SiteLogoUrl
    $Context.Web.Update()
    $Context.ExecuteQuery()
}

# Connect and set the logo for the URL, Trim() is called to remove the trailing white space from the URL
$context = New-Object Microsoft.SharePoint.Client.ClientContext($UrlToUpdate.Trim())
$context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($365AdminUser, $SecurePassword)
Set-WebLogo -Content $context -SiteLogoUrl $LogoUrl
$context.Dispose()