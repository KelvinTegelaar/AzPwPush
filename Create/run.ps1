using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
if ($null -eq $Request.Query.Password) {
    $Password = Invoke-RestMethod -Uri "$($ENV:WEBSITE_HOSTNAME)/Generate"
} else {
    $Password = ($Request.Query.Password)
}
$EncPassword = ($password | ConvertTo-SecureString -Force -AsPlainText) | ConvertFrom-SecureString
$RandomID = get-random -Minimum 1 -Maximum 999999999999999
new-item "PasswordFile_$($randomid)" -Value ($encpassword) -force

$URL = "$($ENV:WEBSITE_HOSTNAME)/api/Get?ID=$RandomID"

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

input[type=submit] {
  width: 35%;
  background-color: #4CAF50;
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

input[type=submit]:hover {
  background-color: #45a049;
  width: 35%
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
  <form action="create" method=GET enctype="text/plain">
    <label for="password">Password</label><br>
    <input type="text" id="password" name="password" value="$($Password)"><br>
    <label for="URL">Unique Password URL</label><br>
    <input type="text" id="URL" name="URL" disabled value="$($URL)"><br><br>

    Use the button below to generate a new URL with the current password field.<br>
    <input type="submit" value="Create">
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
