<#

This script is used to send an email report of computers in SCDPM that haven't been backed up in N days.
Usage: .\Email-ComputersFailingToBackup.ps1 -ProtectionGroup PROT_GRP_1 -StaleAge 2 -SmtpServer smtp.contoso.com -ToAddr "email1@contoso.com","email2@contoso.com"

#>
# Define required variables of the script
[CmdletBinding()]
Param (

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$ProtectionGroup,
    [Parameter(Mandatory = $True, Position = 2)]
    [int]$StaleAge,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$SmtpServer,
    [Parameter(Mandatory = $True, Position = 4)]
    [string[]]$ToAddr = @(),
    [string]$DPMServer = $env:computername

)

# Assemble the HTML Header and CSS for our Report
## Set the HTML formatting.
$HTMLHeader = @"
<style>
BODY{background-color:white;}
TABLE{border-width: 10px;
  border-style: solid;
  border-color: black;
  border-collapse: collapse;
  width=600;
}
TH{border-width: 1px;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  width=1200;
  padding: 5px;
  border-style: solid;
  border-color: black;
  background-color:#C0C0C0
  
}
TD{border-width: 1px;
  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
  padding: 5px;
  border-style: solid;
  border-color: black;
  background-color:white
  
}
</style>
"@

# Assemble the closing HTML for our report.
$HTMLEnd = @"
</div>
</body>
</html>
"@

function SendHtmlTableEmail ($TableData) {

    # Create new table object
    $TableName = "Group Objects"
    $Table = New-Object System.Data.DataTable "$TableName"

    # Create columns for our table
    $col1 = New-Object System.Data.DataColumn "Computer", ([string])
    $col2 = New-Object System.Data.DataColumn "LatestRecoveryPointTime", ([string])

    # Add the columbs to our table
    $Table.Columns.Add($col1)
    $Table.Columns.Add($col2)

    if ($TableData -ne $null) {

        # Loop through each object in the array and create a row from it
        $TableData | ForEach-Object {

            $Row = $Table.NewRow()
            $Row."Computer" = $_."Computer"
            $Row."LatestRecoveryPointTime" = $_."LatestRecoveryPointTime"
            $Table.Rows.Add($Row)
        }
    }
    
    # Convert our table to an html table and remove unwanted columns
    $Table = $Table | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors | ConvertTo-Html -Fragment
    
    # Assemble all the html code
    $HtmlBody = $HTMLHeader + $Table + $HTMLEnd

    # Fire off the email
    Send-MailMessage -SmtpServer $SmtpServer -From "$DPMServer@fau.edu" -To $ToAddr -Subject "$ProtectionGroup Computers Not Backed up Last $StaleAge Days" -BodyAsHtml -Body $HtmlBody
}

# Get a list of computers that haven't been backed up in N days
$ComputersNotBackingUp = Get-DPMDatasource -DPMServerName $DPMServer | `
    Where-Object { $_.ProtectionGroupName -like $ProtectionGroup -and $_.LatestRecoveryPointTime -lt (Get-Date).AddDays(-$StaleAge) } | `
    Select-Object -Property Computer, LatestRecoveryPointTime

# Only send an email if we have computers that havent been backed up
if ( $ComputersNotBackingUp -ne $null ) {

    SendHtmlTableEmail($ComputersNotBackingUp)

}