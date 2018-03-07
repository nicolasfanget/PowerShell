<#

This script generates an encrypted secure string to be used as a secure way to store a password in a file.
If you plan on running a scheduled task as the SYSTEM account with one of these files, make sure to generate
the file using the SYSTEM account. Example: psexec.exe -s powershell -f c:\scripts\generate-encryptedpasswordfile.ps1

#>

# Prompt user for the password to store in encrypted file
$SecurePassword = Read-Host -AsSecureString "Enter the password to store"

# Prompt user for file name to save as
$FileName = Read-Host "Enter file name to save as including extension"

# Generate the encrypted password file
ConvertFrom-SecureString -SecureString $SecurePassword | Out-File ".\$FileName"