# script to get message latency

# define variables
$StartTime = "8/11/2017 9:15:00 AM"
$EndTime = "8/11/2017 10:15:00 AM"

# Get results and store in variable
$MsgTrackingOutput = Get-MessageTrackingLog -EventID "SEND" -Start $StartTime -End $EndTime | Select-Object Timestamp, Sender, ServerHostname, MessageLatency | `
Sort-Object -Descending MessageLatency | Format-Table -AutoSize | Out-String -Width 4096

# Output variable to text file for review
$MsgTrackingOutput | Out-File .\output.txt