using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module .\Modules\AzPwPush.psm1

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

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

$Password = Get-AzPassword -ID $RandomID

if($Password -eq $false) {
  $Password = "No Password found. This password may have already been removed."
}

$Hostname = $Request.Headers.'disguised-host'

$DeleteURL = "https://$($Hostname)/Delete?ID=$RandomID"

# Interact with query parameters or the body of the request.
$Body = @"
<!DOCTYPE html>
<html>

<script>
function myFunction() {
  var copyText = document.getElementById("password");
  copyText.select();
  copyText.setSelectionRange(0, 99999);
  document.execCommand("copy");
  
  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = "Copied to clipboard ";
}

function outFunc() {
  var tooltip = document.getElementById("myTooltip");
  tooltip.innerHTML = "Copy to clipboard";
}
</script>
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

input#password, select {
  width: 70%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

.button {
  background-color: #4CAF50;
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.button:hover {
  background-color: #45a049;
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
  <h3>One time Password</h3>

  <div>
    Please note that this password may only be shown for a limited number of times and may be lost when refreshing. <br>
    <label for="password">Password: </label><br>
    <input type="text" id="password" name="password" value="$($Password)"><br>
    <div class="tooltip">
      <button class="button" onclick="myFunction()" onmouseout="outFunc()">
        <span class="tooltiptext" id="myTooltip">Copy to clipboard</span>
        Copy
      </button>
    </div>
    <button class="button" onclick="document.location.href='$($DeleteURL)'">
      Delete
    </button><br>
  </div>
</center>
</body>
</html>

</html>
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    Body        = $Body
    ContentType = 'text/html'
})
