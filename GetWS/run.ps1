using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module .\Modules\AzPwPush.psm1

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$RandomID = $Request.Query.ID

$ParsedQueryString = [System.Web.HttpUtility]::ParseQueryString($Request.Body)

$i = 0

foreach($QueryStringObject in $ParsedQueryString) {
    if($QueryStringObject -eq "ID") {
      $RandomID = $ParsedQueryString[$i]
    }
    $i++
}

$RandomID = $RandomID.ToUpper()

$Password = Get-AzPassword -ID $RandomID

if($Password -eq $false) {
  $Status = [HttpStatusCode]::NotFound
  $Password = ""
}
else {
  $Status = [HttpStatusCode]::OK
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = $Status
    Body        = $Password
    ContentType = 'text/plain'
})
