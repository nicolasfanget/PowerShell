$UserCredential = Get-Credential -Message "Enter Office365 Credentials"

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
-Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

# Make sure to run the cmdlet below to remove your session when you're done
# Remove-PSSession $Session