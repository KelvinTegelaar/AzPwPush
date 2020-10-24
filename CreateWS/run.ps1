using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$Hostname = $Request.Headers.'disguised-host'

Import-Module .\Modules\AzPwPush.psm1

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$MaxViews = $Request.Query.MaxViews -as [int]
$Password = $Request.Query.Password

$ParsedQueryString = [System.Web.HttpUtility]::ParseQueryString($Request.Body)

$i = 0

foreach($QueryStringObject in $ParsedQueryString) {
    if($QueryStringObject -eq "Password") {
      $Password = $ParsedQueryString[$i]
    }
    elseif($QueryStringObject -eq "MaxViews") {
      $MaxViews = $ParsedQueryString[$i] -as [int]
    }
    elseif($QueryStringObject -eq "Submit") {
      $Submit = $ParsedQueryString[$i]
    }
    $i++
}

if([string]::IsNullOrEmpty($Password)) {
  $Password = (Generate-AzPassword).Replace("\", "\\").Replace("`"","\`"")
}
  
$RandomID = Create-AzPassword -MaxViews $MaxViews -Password $Password
$URL = "https://$($Hostname)/Get?ID=$($RandomID)"

# Interact with query parameters or the body of the request.
$Body = @"
{"Password":"$($Password)","ID":"$($RandomID)"}
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    Body        = $Body
    ContentType = 'application/json'
})
