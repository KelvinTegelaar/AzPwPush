# Input bindings are passed in via param block.
param($Timer)

Import-Module .\Modules\AzPwPush.psm1

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

Cleanup-AzPasswords