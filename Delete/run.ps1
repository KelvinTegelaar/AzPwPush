using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module .\Modules\AzPwPush.psm1

if(-not [string]::IsNullOrEmpty($ENV:LogoImage)) {
  $Logo = "<img src=`"$($ENV:LogoImage)`" alt=`"Logo`">"
}
else {
  $Logo = ""
}

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

$Message = "Password not successfully deleted."

if(-not [string]::IsNullOrEmpty($RandomID)) {
    if((Delete-AzPassword -ID $RandomID) -eq $true) {
        $Message = "Password successfully deleted."
    }
}

# Interact with query parameters or the body of the request.
$Body = @"
<!DOCTYPE html>
<html>
<style>
.tooltip {
    position: relative;
    display: inline-block;
  }
  
  .tooltip .tooltiptext {
    visibility: hidden;
    width: 140px;
    background-color: #555;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    padding: 5px;
    position: absolute;
    z-index: 1;
    bottom: 50%;
    left: 50%;
    margin-left: -75px;
    opacity: 0;
    transition: opacity 0.3s;
  }
  
  .tooltip .tooltiptext::after {
    content: "";
    position: absolute;
    top: 50%;
    left: 50%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: #555 transparent transparent transparent;
  }
  
  .tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
  }

div {
  border-radius: 5px;
  background-color: #f2f2f2;
  padding: 20px;
  width: 40%
}
</style>
<body>
  <center>
    $($Logo)
    <title>Password Push Portal</Title>
    <div>
      $($Message)
    </div>
  </center>
</body>
</html>
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $Body
    ContentType = 'text/html'
})