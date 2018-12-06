<#

This script creates a service account, it reduces a lot of the manual work of creating one

#>

# Get college prefix account will be created for
$CollegeDept = Read-Host -Prompt "Enter college prefix service account will be used by"
$CollegeDept = $CollegeDept.ToUpper()

# Get name of the service account to create
$ServiceAccountName = Read-Host -Prompt "Enter name of the service account"

#Create a text file named after the service account
New-Item -ItemType File -Path ".\" -Name "$ServiceAccountName.txt" -ErrorAction SilentlyContinue -ErrorVariable FileError | Out-Null

if ($FileError) {

    Write-Host -ForegroundColor "Red" "Unable to create file: $ServiceAccountName.txt"
    break

}

# Get the password for the new service account
# Reading this password as plain text goes against best practice, but it makes life easier when creating the txt file to share with
# the department requesting the account. I recommend clearing your console window when the script is finished
$ServiceAccountPassword = Read-Host "Enter service account password"

# Create the service account
try {

    New-ADUser -Name $ServiceAccountName `
                -SamAccountName $ServiceAccountName `
                -UserPrincipalName "$ServiceAccountName@fau.edu" `
                -AccountPassword (ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force) `
                -Path "OU=SERVICE,OU=SYSADMIN,DC=ad,DC=fau,DC=edu" `
                -Enabled $True `
                -PasswordNeverExpires $True `
                -Description "$CollegeDept Service Account"

    # Write account name and password to the text file
    Write-Output "$ServiceAccountName`n$ServiceAccountPassword" | Out-File ".\$ServiceAccountName.txt"

} catch { Write-Host -ForegroundColor "Red" "Unable to create service account: $ServiceAccountName" }
