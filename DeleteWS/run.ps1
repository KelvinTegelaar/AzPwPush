using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module .\Modules\AzPwPush.psm1

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

$Success = $false

if(-not [string]::IsNullOrEmpty($RandomID)) {
    if((Delete-AzPassword -ID $RandomID) -eq $true) {
        $Success = $true
    }
}

$Success = "$($Success)".ToLower()

# Interact with query parameters or the body of the request.
$Body = @"
{"status":$($Success)}
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $Body
    ContentType = 'application/json'
})