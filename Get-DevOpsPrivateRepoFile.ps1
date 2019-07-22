$devOpsAccountName = 'segraef'
$devOpsTeamProjectName = 'Oahu'
$devOpsPAT = 'xxx'
$devOpsBaseUrl = 'https://' + $devOpsAccountName + '.visualstudio.com'

$FileRepo = 'Oahu'
$FileRepoBranch = 'master'
$FilePath = 'Scripts/PowerShell/123.ps1'

$User=""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User,$devOpsPAT)));
$devOpsAuthHeader = @{Authorization=("Basic {0}" -f $base64AuthInfo)};

$Uri = $devOpsBaseUrl + '/' + $devOpsTeamProjectName + '/_apis/git/repositories/' + $FileRepo  + '/items?path=' + $FilePath + '&$format=json&includeContent=true&versionDescriptor.version=' + $FileRepoBranch + '&versionDescriptor.versionType=branch&api-version=4.1'

$File = Invoke-RestMethod -Method Get -ContentType application/json -Uri $Uri -Headers $devOpsAuthHeader

Write-Host $File.content
