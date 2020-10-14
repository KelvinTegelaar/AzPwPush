using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

if ($Request.Query.Style -eq "words") {
    $CharSet = $ENV:CharSet.ToCharArray()
    $RandSymbol = (Get-Random -InputObject $CharSet -count 3) -join ''
    $words = get-content wordlist.txt
    $Password = ($words |  get-random -count 3) -join $RandSymbol
}
else {
    $CharSet = $ENV:CharSet.ToCharArray()
    $Password = (Get-Random -InputObject $CharSet -count $ENV:Length) -join ''
}
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Password
    })