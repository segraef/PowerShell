$policyFolder = ".\"
$managementGroup = Get-AzureRmManagementGroup | Out-GridView -PassThru
$policyDescription = "Apply Diagnostics Settings"

foreach ($item in (Get-Childitem $policyFolder)) {
    $json = Get-Content $item.FullName | ConvertFrom-Json
    $mode = $json.mode | ConvertTo-Json
    $policyRule = $json.policyRule | ConvertTo-Json -Depth 8 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) }
    $parameters = $json.parameters | ConvertTo-Json -Depth 8 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) }
    New-AzureRmPolicyDefinition -Name $item.BaseName -DisplayName $item.BaseName -Policy $policyRule -Description $policyDescription -Parameter $parameters -Mode $json.mode -ManagementGroupName $managementGroup.Name
}
