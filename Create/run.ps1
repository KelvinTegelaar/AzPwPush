using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$Hostname = $Request.Headers.'disguised-host'
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

if ($null -eq $Request.rawbody) {
  $Password = Invoke-RestMethod -Uri "https://$($Hostname)/Generate"
}
else {
  $Password = $Request.rawbody

  if($Request.rawbody.IndexOf("=") -ne -1) {
      $Password = $Password.Substring($Request.rawbody.IndexOf("=") + 1) 
  }

  $Password = [System.Web.HttpUtility]::urldecode($Password)
}

$EncPassword = ($password | ConvertTo-SecureString -Force -AsPlainText) | ConvertFrom-SecureString

while ($true) {
  try {
    $RandomID = New-Guid
    new-item "PasswordFile_$($RandomID)" -Value ($encpassword) -ea stop
    break
  }
  catch{}
}

$URL = "https://$($Hostname)/Get?ID=$RandomID"

# Interact with query parameters or the body of the request.
$Body = @"
<!DOCTYPE html>
<html>
<style>
input[type=text], select {
  width: 35%;
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
<img src="$($ENV:LogoImage)" alt="Logo">
<title>Password Push Portal</Title>
<h3>Generate a one-time password URL</h3>

<div>
  <form action="create" method=POST>
    <label for="password">Password</label><br>
    <input type="text" id="password" name="password" value="$($Password)"><br>
    <label for="URL">Unique Password URL</label><br>
    <input type="text" id="URL" disabled value="$($URL)"><br><br>
    Use the Create button below to generate a new URL with the current password field, or use the Generate button to create a new password<br>
    <input class="button" type="submit" value="Create">  <input onclick="window.location.href='/Create'" class="button" type="button" value="Generate">
  </form>

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
