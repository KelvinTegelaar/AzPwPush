using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
    $CharSet = ('0123456789{]+-[*=@:)}$^%;(_!&#?>/|').ToCharArray() 
    $RandSymbol = (Get-Random -InputObject $CharSet -count 5) -join ''
    $words = [System.IO.file]::ReadAllLines('wordlist.txt') 
    $Password = ($words |  get-random -count 3) + $RandSymbol -join ''

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Password
    })