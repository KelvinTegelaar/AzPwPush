using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$Hostname = $Request.Headers.'disguised-host'

Import-Module .\Modules\AzPwPush.psm1

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

if(-not [string]::IsNullOrEmpty($ENV:LogoImage)) {
  $Logo = "<img src=`"$($ENV:LogoImage)`" alt=`"Logo`">"
}
else {

  $Logo = ""
}

$MaxViews = $Request.Query.MaxViews -as [int]
$Password = $Request.Query.Password
$Submit = $Request.Query.Submit

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


if($null -ne $Submit) {
  if([string]::IsNullOrEmpty($Password)) {
    $Password = Generate-AzPassword
  }
  
  $RandomID = Create-AzPassword -MaxViews $MaxViews -Password $Password
  $URL = "https://$($Hostname)/Get?ID=$($RandomID)"
}
else {
  $URL = ""
}

# Interact with query parameters or the body of the request.
$Body = @"
<!DOCTYPE html>
<html>
<style>
input#password, select {
  width: 70%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

input#URL, select {
  width: 70%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

input#maxviews, select {
  width: 8em;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

.button {
  width: 25%;
  background-color: #4CAF50;
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  border: none;
  border-radius: 20px;
  cursor: pointer;
}

.button:hover {
  background-color: #45a049;
  width: 25%
}
.divider{
  width:5px;
  height:auto;
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
<h3>Generate a one-time password URL</h3>

<div>
  <form action="create" method=POST>
    <label for="password">Password</label><br>
    <input type="text" id="password" name="password" value="$($Password)"><br>
    <label for="maxviews">Maximum Number of Views: </label>
    <input type="text" id="maxviews" name="maxviews" value="2"><br>
    <label for="URL">Unique Password URL</label><br>
    <input type="text" id="URL" disabled value="$($URL)"><br><br>
    Use the Create button below to generate a new URL with the current password field.<br>
    A blank password will result in a randomly generated password.<br>
    A Maximum Number of Views of 0 will allow infinite views (until $($ENV:MaximumPasswordAge) days from creation has expired).<br>
     or use the Generate button to create a new password<br>
    <input class="button" name="Submit" type="submit" value="Create">
  </form>
</div>
  </center>
</body>
</html>
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    Body        = $Body
    ContentType = 'text/html'
})
