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
<p style="font-size:20px;family:calibri;color:#ff9100">
Test Table
</p>
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
    $col1 = New-Object System.Data.DataColumn "Name", ([string])
    $col2 = New-Object System.Data.DataColumn "objectClass", ([string])
    $col3 = New-Object System.Data.DataColumn "SID", ([string])

    # Add the columbs to our table
    $Table.Columns.Add($col1)
    $Table.Columns.Add($col2)
    $Table.Columns.Add($col3)

    if ($TableData -ne $null) {

        # Loop through each object in the array and create a row from it
        $TableData | ForEach-Object {

            $Row = $Table.NewRow()
            $Row."Name" = $_."Name"
            $Row."objectClass" = $_."objectClass"
            $Row."SID" = $_."SID"
            $Table.Rows.Add($Row)
        }
    }
    
    # Convert our table to an html table and remove unwanted columns
    $Table = $Table | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors | ConvertTo-Html -Fragment
    # Assemble all the html code
    $HtmlBody = $HTMLHeader + $Table + $HTMLEnd
    # Fire off the email
    Send-MailMessage -SmtpServer "smtp" -From "test@test.com" -To "test.com" -Subject "Test PowerShell" -BodyAsHtml -Body $HtmlBody
}
