<#
	.NOTES
		==============================================================================================
		Copyright(c) Microsoft Corporation. All rights reserved.

		File:		Export-AzDOBuildReleaseDefinitions.ps1

		Purpose:	PowerShell - Exports -Azure DevOps Build Release Definitions

		Version: 	1.0.0.0 - 1st August 2019 - Sebastian Gräf
		==============================================================================================

    .SYNOPSIS
      Exports build and release definitions from a source Azure DevOps project and imports these into a destination project.
      If no destination project give it will only export build and release defintions and save it as JSON.

    .DESCRIPTION
      The script will create two folders with all exported build and release definitions as JSON.
      Once a destination organization and project are given, the script will import the exported
      build and release defintions into the target project.

      Required Modules (will be installed if not present): VSTeam

    .PARAMETER sourceAccount
        Azure DevOps source account/organization.

    .PARAMETER sourceProject
        Azure DevOps source project.

    .PARAMETER sourcePersonalAccessToken
        Azure DevOps source Personal Access Token.

    .PARAMETER sourcePersonalAccessToken
        Azure DevOps source Secure Access Token.

    .PARAMETER destinationAccount
        Azure DevOps destination account/organization.

    .PARAMETER destinationProject
        Azure DevOps destination account/organization.

    .PARAMETER destinationPersonalAccessToken
        Azure DevOps destination Personal Access Token.

    .PARAMETER destinationSecureAccessToken
        Azure DevOps destination Secure Access Token.
#>

#Requires -Version 5

[CmdletBinding()]
param
(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string]$sourceAccount,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string]$sourceProject,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string]$sourcePersonalAccessToken,
	[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[securestring]$sourceSecureAccessToken,
	[Parameter(Mandatory = $False, ValueFromPipeline = $true)]
	[string]$destinationAccount,
	[Parameter(Mandatory = $False, ValueFromPipeline = $true)]
	[string]$destinationProject,
	[Parameter(Mandatory = $False, ValueFromPipeline = $true)]
	[string]$destinationPersonalAccessToken,
	[Parameter(Mandatory = $False, ValueFromPipeline = $true)]
	[securestring]$destinationSecureAccessToken
)

#region - functions
function Get-IsElevated
{
	#region - Get-IsElevated()
	try
	{
		$WindowsId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($WindowsId)
		$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

		if ($WindowsPrincipal.IsInRole($adminRole))
		{
			return $true
		}
		else
		{
			return $false
		}
	}
	catch [system.exception]
	{
		Write-Output "Error in Get-IsElevated() $($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char:$($psitem.InvocationInfo.OffsetInLine)"
		exit
	}
	#endregion
}

function Import-ADOModule
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[string]$module
	)

	#region - Import-ADOModule()
	try
	{
		if (Get-Module | Where-Object { $psitem.Name -eq $module })
		{
			Write-Output "Module $module is already imported."
		}
		else
		{
			if (Get-Module -ListAvailable | Where-Object { $psitem.Name -eq $module })
			{
				Import-Module $module -Verbose
			}
			else
			{
				if (Find-Module -Name $module | Where-Object { $psitem.Name -eq $module })
				{
					$paramInstallModule = @{
						Name    = $module
						Force   = $true
						Verbose = $true
						Scope   = 'CurrentUser'
					}
					Install-Module @paramInstallModule

					$paramImportModule = @{
						Name    = $module
						Verbose = $true
					}
					Import-Module @paramImportModule
				}
				else
				{
					Write-Output "Module $module not imported, not available and not in online gallery, exiting."
					exit
				}
			}
		}
	}
	catch [system.exception]
	{
		Write-Output "Error in Load-Module() $($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char:$($psitem.InvocationInfo.OffsetInLine)"
		exit
	}
	#endregion
}
#endregion

#region - Export ADO Build Release Definitions
Clear-Host
Write-Output "Script Started"

if (Get-IsElevated)
{
	try
	{
		(Get-Host).UI.RawUI.WindowTitle = "$env:USERDOMAIN\$env:USERNAME (Elevated)"
		$timeSync = Get-Date
		$timeSync = $timeSync.ToString()

		Write-Output "Script is running in an elevated PowerShell host."
		Write-Output "Start time: $timeSync`n"

		#region - Import-ADOModule()
		$paramLoadModule = @{
			module = 'VSTeam'
		}
		Import-ADOModule @paramLoadModule
		#endregion

		#region - Set Source Project
		if ($sourceAccount -and $sourceProject)
		{
			if ($sourcePersonalAccessToken)
			{
				$paramSetVSTeamAccount = @{
					Account			    = $sourceAccount
					PersonalAccessToken = $sourcePersonalAccessToken
				}
				Set-VSTeamAccount @paramSetVSTeamAccount
			}
			elseif ($sourcePersonalAccessToken)
			{
				$paramSetVSTeamAccount = @{
					Account				      = $sourceAccount
					SecurePersonalAccessToken = $sourceSecureAccessToken
				}
				Set-VSTeamAccount @paramSetVSTeamAccount
			}
			else
			{
				Write-Output "Exiting script since no token given"
				exit
			}

			# Get all release definitions
			$paramGetVSTeamReleaseDefinition = @{
				ProjectName = $sourceProject
			}
			$releaseDefinitions = Get-VSTeamReleaseDefinition @paramGetVSTeamReleaseDefinition

			# Get all build definitions
			$paramGetVSTeamBuildDefinition = @{
				ProjectName = $sourceProject
			}
			$buildDefinitions = Get-VSTeamBuildDefinition @paramGetVSTeamBuildDefinition

			# Create definition folders
			$buildDefinitionDirectory = New-Item "$sourceAccount.$sourceProject.BuildDefinitions" -ItemType Directory -Force
			$releaseDefinitionDirectory = New-Item "$sourceAccount.$sourceProject.ReleaseDefinitions" -ItemType Directory -Force

			# Export build defintions
			foreach ($buildDefinition in $buildDefinitions)
			{
				$fileName = $buildDefinitionDirectory.FullName + "\" + $buildDefinition.Name + ".json"
				$paramGetVSTeamBuildDefinition = @{
					ProjectName = $sourceProject
					Id		    = $buildDefinition.ID
					json	    = $true
				}
				Get-VSTeamBuildDefinition @paramGetVSTeamBuildDefinition | Out-File $fileName
			}
			Write-Output "Your build definitions can be found here: $buildDefinitionDirectory"

			# Export release defintions
			foreach ($releaseDefinition in $releaseDefinitions)
			{
				$fileName = $releaseDefinitionDirectory.FullName + "\" + $releaseDefinition.Name + ".json"
				$paramGetVSTeamReleaseDefinition = @{
					ProjectName = $sourceProject
					Id		    = $releaseDefinition.ID
					json	    = $true
				}
				Get-VSTeamReleaseDefinition @paramGetVSTeamReleaseDefinition | Out-File $fileName
			}
			Write-Output "Your release definitions can be found here: $releaseDefinitionDirectory"
		}
		#endregion

		#region - Set Destination Project
		if ($destinationAccount -and $destinationProject)
		{
			if ($destinationPersonalAccessToken)
			{
				Set-VSTeamAccount -Account $destinationAccount -PersonalAccessToken $destinationPersonalAccessToken
			}
			elseif ($destinationSecureAccessToken)
			{
				Set-VSTeamAccount -Account $sourceAccount -SecurePersonalAccessToken $destinationSecureAccessToken
			}
			else
			{
				Write-Output "Exiting script since no token given"
			}

			# Import release defintions
			$releaseDefinitions = Get-ChildItem $releaseDefinitionDirectory.FullName
			foreach ($releaseDefinition in $releaseDefinitions)
			{
				$fileName = $releaseDefinition.FullName
				$paramAddVSTeamReleaseDefinition = @{
					ProjectName = $destinationProject
					inFile	    = $fileName
				}
				Add-VSTeamReleaseDefinition @paramAddVSTeamReleaseDefinition
			}

			# Import build defintions
			$buildDefinitions = Get-ChildItem $buildDefinitionDirectory.FullName
			foreach ($buildDefinition in $buildDefinitions)
			{
				$fileName = $buildDefinition.FullName
				$paramAddVSTeamReleaseDefinition = @{
					ProjectName = $destinationProject
					inFile	    = $fileName
				}
				Add-VSTeamReleaseDefinition @paramAddVSTeamReleaseDefinition
			}
		}
		#endregion

		$timeSync = Get-Date
		$timeSync = $timeSync.ToString()
		Write-Output "`nEnded at: $timeSync"
	}
	catch [system.exception]
	{
		Write-Output "Error:$($psitem.Exception.Message) Line:$($psitem.InvocationInfo.ScriptLineNumber) Char:$($psitem.InvocationInfo.OffsetInLine)"
		exit
	}
}
else
{
	Write-Output "Please start the script from an elevated PowerShell host."
	exit
}

Write-Output "Script Completed."
#endregion