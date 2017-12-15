# This script flushes the scom agent cache

# stop the agent health service
Stop-Service HealthService

# remove the cache
Get-ChildItem -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State" | Remove-Item -Force -Recurse

# start the agent health service
Start-Service HealthService