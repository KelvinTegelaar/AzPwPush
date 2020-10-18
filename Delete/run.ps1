using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$RandomID = $Request.Query.ID
try {
  Remove-item "PasswordFile_$($RandomID)" -force -ErrorAction Stop
  $State = "Password $($RandomID) has been deleted"
}
catch {
  $State = "No Password found. This password has already been removed"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    Body        = $State
    ContentType = 'text/html'
  })
