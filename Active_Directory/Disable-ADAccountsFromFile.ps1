<#

This script was written to go through a text file and disable the accounts in Active Directory
This works well cause the input I got was from an email/excel document, so cherrypicking it was the easiest route

#>


# Get text file with accounts to disable
$InputFile = Get-Content "C:\Scripts\PowerShell\irm_account_disables.txt" -ErrorAction SilentlyContinue -ErrorVariable FileError

if ($FileError) {
    
    Write-Host -ForegroundColor "Red" "Unable to access txt file with accounts.`nPlease verify file exists and is accessible by the account running this script."
    break

}


# Specify domain accounts reside on (domain controller on the domain)
$DomainController = "BOCDCIRM01.irm.ad.fau.edu"

# Get the date and put it into a string
$DateString = (Get-Date -Format yyyyMMdd).ToString()

# Loop through the accounts in the input file
$InputFile | ForEach-Object {

    # Convert the line of text to a string and remove leading and trailing white spaces
    $UserToDisable = $_.ToString()
    $UserToDisable = $UserToDisable.Trim()

    # Disable the account
    try {

        Set-ADUser -Identity $UserToDisable -Server $DomainController -Enabled $False -Description "Disabled $DateString -FH"
        Write-Host "Disabled account: $UserToDisable"

    }
    catch { Write-Host -ForegroundColor "Red" "Unable to disable: $UserToDisable" }
}